require_relative './schema/attribute_definition'
require_relative './schema/resource_definition'

module Syncano
  class Schema
    SCHEMA_PATH = 'schema/'

    attr_reader :schema

    def initialize(connection)
      self.connection = connection
      load_schema
    end

    def process!
      schema.each do |resource_name, resource_definition|
        self.class.generate_resource_class(resource_name, resource_definition)
        if resource_definition[:collection].present? && resource_definition[:collection][:path].scan(/\{([^}]+)\}/).empty?
          self.class.generate_client_method(resource_name)
        end
      end
    end

    private

    attr_accessor :connection
    attr_writer :schema

    def load_schema
      raw_schema = connection.request(:get, SCHEMA_PATH)
      resources = {}

      raw_schema.each do |resource_schema|
        class_name = resource_schema['name']

        resources[class_name] = {
            attributes: {},
            associations: {},
            collection: nil,
            member: nil,
            custom_methods: []
        }

        fields = resource_schema['endpoints']['list'].try(:[], 'fields') || {}

        resources[class_name][:attributes].merge! fields

        if fields['links']
          resources[class_name][:attributes].delete('links')
          resources[class_name][:associations].merge!(fields['links'])
        end

        resource_schema['endpoints'].each do |type, endpoint|
          endpoint_data = {
              path: endpoint['path'],
              http_methods: endpoint['methods'],
              params: endpoint['properties']
          }

          if type == 'list'
            resources[class_name][:collection] = endpoint_data
          elsif type == 'detail'
            resources[class_name][:member] = endpoint_data
          else
            endpoint_data.merge!(name: type)
            resources[class_name][:custom_methods] << endpoint_data
          end
        end
      end

      self.schema = resources
    end

    class << self
      def generate_client_method(resource_name)
        method_name = resource_name.tableize
        resource_class = "::Syncano::Resources::#{resource_name}".constantize

        ::Syncano::API.send(:define_method, method_name) do
          ::Syncano::QueryBuilder.new(connection, resource_class)
        end
      end

      def generate_resource_class(name, definition_hash)
        delete_colliding_links definition_hash

        resource_definition = ::Syncano::Schema::ResourceDefinition.new(definition_hash)

        ::Syncano::Resources.define_resource name, resource_definition
      end

      def delete_colliding_links(definition)
        definition[:attributes].each do |k, v|
          definition[:associations]['links'].delete_if { |link| link['name'] == k } if definition[:associations]['links']
        end
      end
    end
  end
end