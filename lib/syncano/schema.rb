require_relative './schema/attribute_definition'
require_relative './schema/resource_definition'
require 'singleton'

module Syncano
  class Schema
    SCHEMA_PATH = 'schema/'

    attr_reader :schema

    def initialize(connection = ::Syncano::Connection.new)
      self.connection = connection
    end

    # def process
    #   # TODO pass a class to define resources within
    #
    #   schema.each do |name, raw_resource_definition|
    #     resource_definition = ::Syncano::Schema::ResourceDefinition.new(name, raw_resource_definition)
    #     resource_class = ::Syncano::Resources.define_resource_class(resource_definition)
    #
    #     if resource_definition[:collection].present? && resource_definition[:collection][:path].scan(/\{([^}]+)\}/).empty?
    #       self.class.generate_client_method(name, resource_class)
    #     end
    #   end
    # end


    attr_accessor :connection

    def definition
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

      resources
    end

    # class << self
    #   def generate_client_method(resource_name, resource_class)
    #     method_name = resource_name.tableize
    #
    #     ::Syncano::API.send(:define_method, method_name) do
    #       ::Syncano::QueryBuilder.new(connection, resource_class)
    #     end
    #   end
    # end
  end
end