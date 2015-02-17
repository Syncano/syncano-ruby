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
        generate_resource_class(resource_name, resource_definition)
        generate_client_method(resource_name, resource_definition)
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

        resources[class_name][:attributes].merge!(resource_schema['properties'])

        if resource_schema['properties']['links'].present?
          resources[class_name][:attributes].delete('links')
          resources[class_name][:associations].merge!(resource_schema['properties']['links'])
        end

        resource_schema['endpoints'].each do |type, endpoint|
          endpoint_data = {
              path: endpoint['path'].gsub("/#{Syncano::Connection::API_VERSION}/", ''),
              http_methods: endpoint['methods'],
              params: endpoint['properties']
          }

          if type == 'list'
            resources[class_name][:collection] = endpoint_data
          elsif type == 'detail'
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
      attributes = []

      definition[:attributes].each do |attribute_name, attribute|
        attributes << {
          name: attribute_name,
          type: self.class.map_syncano_attribute_type(attribute['type']),
          presence_validation: attribute['required']
        }
      end


      resource_class = ::Class.new(::Syncano::Resources::Base) do
        attributes.each do |attribute_definition|
          attribute attribute_definition[:name], type: attribute_definition[:type]
          validates attribute_definition[:name], presence: true if attribute_definition[:presence_validation]
        end

        (definition[:associations]['links'] || []).each do |association_schema|
          if association_schema['type'] == 'list'
            define_method(association_schema['name']) do
              has_many_association(association_schema['name'])
            end
          elsif association_schema['type'] == 'detail' && association_schema['name'] != 'self'
            define_method(association_schema['name']) do
              belongs_to_association(association_schema['name'])
            end
          end
        end

        private

        self.resource_definition = definition
      end

      ::Syncano::Resources.const_set(name, resource_class)
    end

    def generate_client_method(resource_name, definition)
      method_name = resource_name.tableize
      resource_class = "::Syncano::Resources::#{resource_name}".constantize

      ::Syncano::API.send(:define_method, method_name) do
        ::Syncano::QueryBuilder.new(connection, resource_class)
      end
    end

    def self.map_syncano_attribute_type(type)
      mapping = HashWithIndifferentAccess.new(
        string: ::String,
        email: ::String,
        choice: ::String,
        slug: ::String,
        integer: ::Integer,
        float: ::Float,
        date: ::Date,
        datetime: ::DateTime
      )

      type.present? ? mapping[type] : Object
    end
  end
end