require_relative './schema/attribute_definition'
require_relative './schema/resource_definition'
require_relative './schema/endpoints_whitelist'

require 'singleton'

module Syncano
  class Schema

    attr_reader :schema

    def self.schema_path
      "/#{Syncano::Connection::API_VERSION}/schema/"
    end

    def initialize(connection = ::Syncano::Connection.new)
      self.connection = connection
    end

    attr_accessor :connection

    def definition
      raw_schema = connection.request(:get, self.class.schema_path)
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

      resources
    end
  end
end