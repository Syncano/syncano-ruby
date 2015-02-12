module Syncano
  module Resources
    class Base
      include ActiveAttr::Model
      include ActiveAttr::Dirty

      def initialize(connection, attributes = {})
        self.connection = connection
        attributes = HashWithIndifferentAccess.new(attributes)
        attributes.delete(:links)
        self.attributes = attributes
      end

      def self.all(connection, scope_parameters = {})
        check_resource_method_existance!(:index)
        response = connection.request(:get, resource_definition[:collection][:path])
        response['objects'].collect do |resource_attributes|
          new_from_database(connection, resource_attributes)
        end
      end

      def self.find(connection, pk, scope_parameters = {})
        check_resource_method_existance!(:show)
        response = connection.request(:get, resource_definition[:member][:path].gsub("{#{primary_key_name}}", pk.to_s))
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

      private

      class_attribute :resource_definition
      attr_accessor :connection, :links

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

      def has_collection_actions?
        resource_definition[:collection].present?
      end

      def has_member_actions?
        resource_definition[:member].present?
      end

      def self.primary_key_name
        resource_definition[:member][:path].scan(/\{([^}]+)\}/).last.first
      end

      def has_many_association(name)
        resource_class = "::Syncano::Resources::#{name.camelize.singularize}".constantize
        ::Syncano::QueryBuilder.new(connection, resource_class)
      end

      def belongs_to_association(name)
        resource_class = "::Syncano::Resources::#{name.camelize}".constantize
        ::Syncano::QueryBuilder.new(connection, resource_class)
      end
    end
  end
end