module Syncano
  module Resources
    class Base
      include ActiveAttr::Model
      include ActiveModel::Dirty

      PARAMETER_REGEXP = /\{([^}]+)\}/

      class << self
        def all(connection, scope_parameters, query_params = {})
          check_resource_method_existance!(:index)

          response = connection.request(:get, collection_path(scope_parameters), query_params)
          scope = Syncano::Scope.new(connection, scope_parameters)
          Syncano::Resources::Collection.from_database(response, scope, self)
        end

        def first(connection, scope_parameters, query_params = {})
          all(connection, scope_parameters, query_params).first
        end

        def last(connection, scope_parameters, query_params = {})
          all(connection, scope_parameters, query_params).last
        end

        def find(connection, scope_parameters, pk)
          check_resource_method_existance!(:show)
          return unless pk.present?

          response = connection.request(:get, member_path(pk, scope_parameters))
          new(connection, scope_parameters, response, true)
        end

        def create(connection, scope_parameters, attributes)
          check_resource_method_existance!(:create)

          new(connection, scope_parameters, attributes).save
        end

        def destroy(connection, scope_parameters, pk)
          check_resource_method_existance! :destroy

          connection.request :delete, member_path(pk, scope_parameters)
        end

        def map_attributes_values(attributes)
          attributes.each do |name, value|
            attributes[name] = value.to_json if value.is_a?(Array) || value.is_a?(Hash)
          end

          attributes
        end

        def extract_scope_parameters(path)
          return {} if scope_parameters_names.empty?

          pattern = collection_path_schema.sub('/', '\/')

          scope_parameters_names.each do |parameter_name|
            pattern.sub!("{#{parameter_name}}", '([^\/]+)')
          end

          pattern = Regexp.new(pattern)
          parameter_values = path.scan(pattern).first

          Hash[*scope_parameters_names.zip(parameter_values).flatten]
        end

        def extract_primary_key(path)
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
      end

      def initialize(connection, scope_parameters, attributes, from_database = false)
        self.connection = connection
        self.scope_parameters = scope_parameters

        initialize!(attributes, from_database)
      end

      def primary_key
        self.class.extract_primary_key(association_paths[:self])
      end

      def new_record?
        new_record
      end

      def saved?
        !new_record? && !changed?
      end

      def update_attributes(attributes)
        check_resource_method_existance!(:update)
        raise(Syncano::Error.new('record is not saved')) if new_record?

        self.attributes = attributes
        save
      end

      def save
        # TODO: Call validation here

        if new_record?
          response = connection.request(:post, collection_path, select_create_attributes)
        else
          response = connection.request(:patch, self_path, select_changed_attributes)
        end

        initialize!(response, true)
      end

      def destroy
        check_resource_method_existance!(:destroy)
        connection.request(:delete, self_path)
        mark_as_destroyed!
      end

      def destroyed?
        !!destroyed
      end

      def reload!
        raise(Syncano::Error.new('record is not saved')) if new_record?

        response = connection.request(:get, self_path)
        initialize!(response)
      end

      def attribute_definitions
        self.class.resource_definition.attributes
      end

      def attribute_definitions_map
        Hash[ attribute_definitions.map { |attr| [attr.name, attr] } ]
      end

      def select_create_attributes
        attributes = self.attributes.select { |name, _|
          begin
            attribute_definitions_map[name].writable?
          rescue NoMethodError
            if custom_attributes.has_key?(name)
              true
            else
              raise
            end
          end
        }
        attributes = custom_attributes.merge(attributes) if respond_to?(:custom_attributes)
        self.class.map_attributes_values(attributes)
      end

      def select_update_attributes
        attributes = updatable_attributes
        attributes = custom_attributes.merge(attributes) if respond_to?(:custom_attributes)
        self.class.map_attributes_values(attributes)
      end

      def select_changed_attributes
        updatable_attributes
      end

      def updatable_attributes
        attributes = self.attributes.select do |name, _value|
          self.class.update_writable_attributes.include?(name.to_sym)
        end
        self.class.map_attributes_values attributes
      end

      private

      class_attribute :resource_definition, :create_writable_attributes,
                      :update_writable_attributes
      attr_accessor :connection, :association_paths, :member_path,
                    :scope_parameters, :destroyed, :self_path, :new_record

      def initialize!(attributes = {}, from_database = false)
        attributes = HashWithIndifferentAccess.new(attributes)

        self.member_path = attributes[:links].try(:[], :self)
        self.self_path = attributes[:links].try(:[], :self)
        self.new_record = !from_database # TODO use from_database of self_path.nil?

        initialize_associations(attributes)

        self.attributes.clear
        self.attributes = attributes.except!(:links)

        if from_database && self.class.attributes.keys.include?('custom_attributes')
          self.custom_attributes = attributes.select{ |k, v| !self.attributes.keys.include?(k) }
        end

        apply_defaults

        mark_as_saved! if !new_record? && from_database

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

      def map_collection_name_to_resource_class(name)
        ::Syncano::Resources::Paths.instance.collections.match(association_paths[name])
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

        resource_class = map_collection_name_to_resource_class(name)
        scope_parameters = resource_class.extract_scope_parameters(association_paths[name])

        ::Syncano::QueryBuilder.new(connection, resource_class, scope_parameters)
      end

      def custom_method(method_name, config)
        connection.request self.class.custom_method_http_method(method_name),
                           self.class.custom_method_path(method_name, primary_key, scope_parameters),
                           config
      end

      def self.custom_method_http_method(method_name)
        custom_method_definition(method_name)[:http_methods].first.to_sym
      end

      def self.collection_path_schema
        resource_definition[:collection][:path].dup
      end

      def self.member_path_schema
        resource_definition[:member][:path].dup
      end

      def self.custom_method_path_schema(method_name)
        custom_method_definition(method_name)[:path].dup
      end

      def self.custom_method_definition(method_name)
        resource_definition[:custom_methods].find do |method_definition|
          method_definition[:name] == method_name
        end or raise "No such method #{method_name}"
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

      def self.custom_method_path(name, pk, scope_parameters)
        path = custom_method_path_schema(name)

        scope_parameters_names.each do |scope_parameter_name|
          path.sub!("{#{scope_parameter_name}}", scope_parameters[scope_parameter_name])
        end

        path.sub!("{#{primary_key_name}}", pk.to_s)

        path
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

      def check_resource_method_existance!(method_name)
        self.class.check_resource_method_existance!(method_name)
      end

      {
        index: { type: :collection, method: :get },
        create: { type: :collection, method: :post },
        show: { type: :member, method: :get },
        update: { type: :member, method: :patch },
        destroy: { type: :member, method: :delete }
      }.each do |name, parameters|

        define_singleton_method(name.to_s + '_implemented?') do
          send("has_#{parameters[:type]}_actions?") and resource_definition[parameters[:type]][:http_methods].include?(parameters[:method].to_s)
        end
      end
    end
  end
end
