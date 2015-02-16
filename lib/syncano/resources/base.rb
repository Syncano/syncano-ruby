require 'syncano/resources/concerns/routing'
require 'syncano/resources/concerns/associations'

module Syncano
  module Resources
    class Base
      include ActiveAttr::Model
      include Syncano::Resources::RoutingConcern
      include Syncano::Resources::AssociationsConcern

      def initialize(connection, attributes = {})
        self.connection = connection
        attributes = HashWithIndifferentAccess.new(attributes)

        initialize_routing(attributes)
        initialize_associations(attributes)

        self.attributes = attributes.except!(:links)
      end

      def self.all(connection, scope_parameters = {})
        check_resource_method_existance!(:index)

        response = connection.request(:get, collection_path(scope_parameters))
        response['objects'].collect do |resource_attributes|
          new_from_database(connection, resource_attributes)
        end
      end

      def self.find(connection, pk, scope_parameters = {})
        check_resource_method_existance!(:show)

        response = connection.request(:get, member_path(pk, scope_parameters))
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

        connection.request(:delete, member_path(pk, scope_parameters))
      end

      private

      class_attribute :resource_definition
      attr_accessor :connection

      def self.new_from_database(connection, attributes = {})
        new(connection, attributes)
      end

      def self.map_name_to_resource_class(name)
        "::Syncano::Resources::#{name.camelize.singularize}".constantize
      end
    end
  end
end