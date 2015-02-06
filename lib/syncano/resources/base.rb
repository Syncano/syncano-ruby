module Syncano
  module Resources
    class Base
      include ActiveAttr::Model

      def initialize(connection, attributes = {})
        self.connection = connection
      end

      def self.all(connection)
        check_resource_method_existance!(:index)
        connection.request(:get, resource_definition[:collection][:path])
      end

      def self.find(connection, id)
        check_resource_method_existance!(:show)
        connection.request(:get, resource_definition[:collection][:path], id: id)

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
      attr_accessor :connection

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
    end
  end
end