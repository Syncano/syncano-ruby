module Syncano
  module Resources
    class Base
      include ActiveAttr::Model
      include ActiveAttr::Dirty

      PARAMETER_REGEXP = /\{([^}]+)\}/

      attr_reader :destroyed

      def initialize(connection, scope_parameters, attributes)
        self.connection = connection
        self.scope_parameters = scope_parameters

        reinitialize!(attributes)
        apply_defaults
      end

      def new_record?
        primary_key.blank?
      end

      def saved?
        !new_record? && !changed?
      end

      def self.all(connection, scope_parameters)
        check_resource_method_existance!(:index)

        response = connection.request(:get, collection_path(scope_parameters))
        response['objects'].collect do |resource_attributes|
          new(connection, scope_parameters, resource_attributes)
        end
      end

      def self.first(connection, scope_parameters)
        all(connection, scope_parameters).first
      end

      def self.last(connection, scope_parameters)
        all(connection, scope_parameters).last
      end

      def self.find(connection, scope_parameters, pk)
        check_resource_method_existance!(:show)

        response = connection.request(:get, member_path(pk, scope_parameters))
        new(connection, response)
      end

      def self.create(connection, scope_parameters, attributes)
        check_resource_method_existance!(:create)

        new(connection, attributes, scope_parameters).save
      end

      def update_attributes(attributes)
        check_resource_method_existance!(:update)
        raise(Syncano::Error.new('record is not saved')) if new_record?

        self.attributes = attributes
        self.save
      end

      def save
        # TODO Call validation here
        apply_forced_defaults!

        if new_record?
          response = connection.request(:post, collection_path, select_create_attributes)
        else
          response = connection.request(:put, member_path, select_update_attributes)
        end

        reinitialize!(response)
      end

      def destroy
        check_resource_method_existance!(:destroy)
        connection.request(:delete, member_path)
        mark_as_destroyed!
      end

      def reload!
        raise(Syncano::Error.new('record is not saved')) if new_record?

        response = connection.request(:get, member_path)
        reinitialize!(response)
      end

      def select_create_attributes
        attributes = self.attributes.select { |name, value| self.class.create_writable_attributes.include?(name.to_sym) }
        self.class.map_attributes_values(attributes)
      end

      def select_update_attributes
        attributes = self.attributes.select{ |name, value| self.class.update_writable_attributes.include?(name.to_sym) }
        self.class.map_attributes_values(attributes)
      end

      def self.map_attributes_values(attributes)
        attributes.each do |name, value|
          if value.is_a?(Hash)
            attributes[name] = value.to_json
          end
        end

        attributes
      end

      def self.extract_scope_parameters(path)
        return {} if scope_parameters_names.empty?

        pattern = collection_path_schema.sub('/', '\/')

        scope_parameters_names.each do |parameter_name|
          pattern.sub!("{#{parameter_name}}", '([^\/]+)')
        end

        pattern = Regexp.new(pattern)
        parameter_values = path.scan(pattern).first

        Hash[*scope_parameters_names.zip(parameter_values).flatten]
      end

      def self.extract_primary_key(path)
        return nil if path.blank?

        pattern = member_path_schema.gsub('/', '\/')

        scope_parameters_names.each do |parameter_name|
          pattern.sub!("{#{parameter_name}}", '([^\/]+)')
        end

        pattern.sub!("{#{primary_key_name}}", '([^\/]+)')

        pattern = Regexp.new(pattern)
        parameter_values = path.scan(pattern).first
        parameter_values.last
      end

      private

      class_attribute :resource_definition, :create_writable_attributes, :update_writable_attributes
      attr_accessor :connection, :association_paths, :member_path, :scope_parameters
      attr_writer :destroyed

      def reinitialize!(attributes = {})
        attributes = HashWithIndifferentAccess.new(attributes)

        initialize_routing(attributes)
        initialize_associations(attributes)

        self.attributes.clear
        self.attributes = attributes.except!(:links)
        mark_as_saved! unless new_record?

        self
      end

      def initialize_associations(attributes)
        self.association_paths = HashWithIndifferentAccess.new

        if attributes[:links].present?
          attributes[:links].keys.each do |key|
            association_paths[key] = attributes[:links][key]
          end
        end
      end

      def initialize_routing(attributes)
        self.member_path = attributes[:links].try(:[], :self)
      end

      def self.map_member_name_to_resource_class(name)
        "::Syncano::Resources::#{name.camelize}".constantize
      end

      def self.map_collection_name_to_resource_class(name)
        map_member_name_to_resource_class(name.singularize)
      end

      def apply_forced_defaults!
        self.class.attributes.each do |attr_name, attr_definition|
          if read_attribute(attr_name).blank? && attr_definition[:force_default]
            write_attribute(attr_name, attr_definition[:default])
          end
        end
      end

      def mark_as_saved!
        raise(Syncano::Error.new('primary key is blank')) if new_record?

        @previously_changed = changes
        @changed_attributes.clear
        self
      end

      def mark_as_destroyed!
        self.destroyed = true
      end

      def has_many_association(name)
        # TODO Implement QueryBuilders without scope parameters and adding objects to the association
        raise(Syncano::Error.new('record not saved')) if new_record?

        resource_class = self.class.map_collection_name_to_resource_class(name)
        scope_parameters = resource_class.extract_scope_parameters(association_paths[name])

        ::Syncano::QueryBuilder.new(connection, resource_class, scope_parameters)
      end

      def belongs_to_association(name)
        resource_class = self.class.map_member_name_to_resource_class(name)
        scope_parameters = resource_class.extract_scope_parameters(association_paths[name])
        pk = resource_class.extract_primary_key(association_paths[name])

        ::Syncano::QueryBuilder.new(connection, resource_class, scope_parameters).find(pk)
      end

      def self.collection_path_schema
        resource_definition[:collection][:path].dup
      end

      def self.member_path_schema
        resource_definition[:member][:path].dup
      end

      def self.scope_parameters_names
        collection_path_schema.scan(PARAMETER_REGEXP).collect{ |matches| matches.first.to_sym }
      end

      def self.has_collection_actions?
        resource_definition[:collection].present?
      end

      def self.has_member_actions?
        resource_definition[:member].present?
      end

      def self.check_resource_method_existance!(method_name)
        raise(NoMethodError.new) unless send("#{method_name}_implemented?")
      end

      def self.primary_key_name
        resource_definition[:member][:path].scan(PARAMETER_REGEXP).last.first if has_member_actions?
      end

      def self.collection_path(scope_parameters = {})
        path = collection_path_schema

        scope_parameters_names.each do |scope_parameter_name|
          path.sub!("{#{scope_parameter_name}}", scope_parameters[scope_parameter_name])
        end

        path
      end

      def self.member_path(pk, scope_parameters = {})
        path = member_path_schema

        scope_parameters_names.each do |scope_parameter_name|
          path.sub!("{#{scope_parameter_name}}", scope_parameters[scope_parameter_name])
        end

        path.sub!("{#{primary_key_name}}", pk.to_s)

        path
      end

      def collection_path
        self.class.collection_path(scope_parameters)
      end

      def member_path
        self.class.member_path(primary_key, scope_parameters)
      end

      def primary_key
        self.class.extract_primary_key(association_paths[:self])
      end

      def check_resource_method_existance!(method_name)
        self.class.check_resource_method_existance!(method_name)
      end

      {
        index: { type: :collection, method: :get },
        create: { type: :collection, method: :post },
        show: { type: :member, method: :get },
        update: { type: :member, method: :put },
        destroy: { type: :member, method: :delete }
      }.each do |name, parameters|

        define_singleton_method(name.to_s + '_implemented?') do
          send("has_#{parameters[:type]}_actions?") and resource_definition[parameters[:type]][:http_methods].include?(parameters[:method].to_s)
        end
      end
    end
  end
end