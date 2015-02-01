module Syncano
  class Schema
    SCHEMA_PATH = '/schema/'

    attr_reader :schema

    def initialize(connection)
      self.connection = connection
      load_schema
    end

    def process!
      schema.each do |resource_name, resource_definition|
        generate_resource_class(resource_name, resource_definition)
      end
    end

    private

    attr_accessor :connection
    attr_writer :schema

    def load_schema
      raw_schema = connection.request(SCHEMA_PATH)
      resources = {}

      raw_schema.each do |resource_schema|
        class_name = resource_schema['name']
        class_name = 'Data' + class_name if ['Class', 'Object'].include?(class_name)

        resources[class_name] = {
            attributes: {},
            associations: {},
            collection: nil,
            member: nil,
            custom_methods: []
        }

        resources[class_name][:attributes].merge!(resource_schema['properties'])
        if resource_schema['properties']['links'].present?
          resources[class_name][:attributes].delete('links')
          resources[class_name][:associations].merge(resource_schema['properties']['links'])
        end

        resource_schema['endpoints'].each do |type, endpoint|
          endpoint_data = {
              path: endpoint['path'],
              http_methods: endpoint['methods'],
              params: endpoint['properties']
          }

          if type == 'list'
            resources[class_name][:collection] = endpoint_data
          elsif type == 'details'
            resources[class_name][:member] = endpoint_data
          else
            endpoint_data.merge(name: type)
            resources[class_name][:custom_methods] << endpoint_data
          end
        end
      end

      self.schema = resources
    end

    def generate_resource_class(name, definition)
      resource_class = Class.new(::Syncano::Resources::Base) do

        definition[:attributes].keys.each do |attribute|
          attr_accessor attribute
        end

        private

        self.resource_definition = definition
      end

      ::Syncano::Resources.const_set(name, resource_class)
    end
  end
end