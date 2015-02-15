module Syncano
  module Resources
    class Base
      include ActiveAttr::Model

      def initialize(connection, attributes = {})
        self.connection = connection
        attributes = HashWithIndifferentAccess.new(attributes)

        self.association_paths = attributes.delete(:links)
        association_paths.keys.each do |key|
          association_paths[key] = association_paths[key].gsub("/#{Syncano::Connection::API_VERSION}/", '')
        end

        self.attributes = attributes
      end

      def self.all(connection, scope_parameters = {})
        check_resource_method_existance!(:index)

        path = resource_definition[:collection][:path].dup
        scope_parameters.keys.each do |parameter|
          path.gsub!("{#{parameter}}", scope_parameters[parameter])
        end

        response = connection.request(:get, path)
        response['objects'].collect do |resource_attributes|
          new_from_database(connection, resource_attributes)
        end
      end

      def self.find(connection, pk, scope_parameters = {})
        check_resource_method_existance!(:show)

        path = resource_definition[:member][:path].dup
        scope_parameters.keys.each do |parameter|
          path.gsub!("{#{parameter}}", scope_parameters[parameter])
        end
        path.gsub!("{#{primary_key_name}}", pk.to_s)

        response = connection.request(:get, path)
        new_from_database(connection, response)
      end

      def self.create(connection, attributes = {})
        check_resource_method_existance!(:create)
      end

      def update_attributes(attributes)
        check_resource_method_existance!(:update)
      end

      def destroy
        check_resource_method_existance!(:destroy)
      end

      def self.collection_path
        resource_definition[:collection][:path] if has_collection_actions?
      end

      private

      class_attribute :resource_definition
      attr_accessor :connection, :association_paths

      def self.new_from_database(connection, attributes = {})
        resource = new(connection, attributes)
      end

      def self.check_resource_method_existance!(method_name)
        raise(NoMethodError.new) unless resource_method_implemented?(method_name)
      end

      def self.resource_method_implemented?(method_name)
        resource_definition.present? && send("#{method_name}_implemented?")
      end

      def self.index_implemented?
        resource_definition[:collection][:http_methods].include?('get')
      end

      def self.create_implemented?
        resource_definition[:collection][:http_methods].include?('post')
      end

      def self.show_implemented?
        resource_definition[:member][:http_methods].include?('get')
      end

      def self.update_implemented?
        resource_definition[:member][:http_methods].include?('put')
      end

      def self.destroy_implemented?
        resource_definition[:member][:http_methods].include?('delete')
      end

      def self.has_collection_actions?
        resource_definition[:collection].present?
      end

      def self.has_member_actions?
        resource_definition[:member].present?
      end

      def self.primary_key_name
        resource_definition[:member][:path].scan(/\{([^}]+)\}/).last.first
      end

      def has_many_association(name)
        resource_class = "::Syncano::Resources::#{name.camelize.singularize}".constantize

        collection_path = resource_class.collection_path
        association_path = association_paths[name]

        parameter_names = collection_path.scan(/\{([^}]+)\}/).collect{ |matches| matches.first.to_sym }

        pattern = collection_path.gsub('/', '\/')
        parameter_names.each do |parameter_name|
          pattern.gsub!("{#{parameter_name}}", '([^\/]+)')
        end
        pattern = Regexp.new(pattern)

        parameter_values = association_path.scan(pattern).first
        scope_parameters = Hash[*parameter_names.zip(parameter_values).flatten]

        ::Syncano::QueryBuilder.new(connection, resource_class, scope_parameters)
      end

      def belongs_to_association(name)
        resource_class = "::Syncano::Resources::#{name.camelize}".constantize
        ::Syncano::QueryBuilder.new(connection, resource_class)
      end
    end
  end
end