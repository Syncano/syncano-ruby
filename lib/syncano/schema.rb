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

    def self.generate_resource_class(name, definition)
      resource_class = new_resource_class(name, definition)

      ::Syncano::Resources.const_set(name, resource_class)
    end

    def self.new_resource_class(name, definition)
      attributes_definitions = []

      definition[:attributes].each do |attribute_name, attribute|
        attributes_definitions << {
            name: attribute_name,
            type: map_syncano_attribute_type(attribute['type']),
            default: default_value_for_attribute(attribute),
            presence_validation: attribute['required'],
            length_validation_options: extract_length_validation_options(attribute),
            inclusion_validation_options: extract_inclusion_validation_options(attribute),
            create_writeable: attribute['read_only'] == false,
            update_writeable: attribute['read_only'] == false,
        }
      end

      ::Class.new(::Syncano::Resources::Base) do
        self.create_writable_attributes = []
        self.update_writable_attributes = []

        attributes_definitions.each do |attribute_definition|
          attribute attribute_definition[:name], type: attribute_definition[:type], default: attribute_definition[:default], force_default: !attribute_definition[:default].nil?
          validates attribute_definition[:name], presence: true if attribute_definition[:presence_validation]
          validates attribute_definition[:name], length: attribute_definition[:length_validation_options]

          if attribute_definition[:inclusion_validation_options]
            validates attribute_definition[:name], inclusion: attribute_definition[:inclusion_validation_options]
          end

          self.create_writable_attributes << attribute_definition[:name].to_sym if attribute_definition[:create_writeable]
          self.update_writable_attributes << attribute_definition[:name].to_sym if attribute_definition[:update_writeable]
        end

        if name == 'Object'
          attribute :custom_attributes, type: ::Object, default: nil, force_default: true
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
          elsif association_schema['type'] == 'run'
            define_method(association_schema['name']) do |config = nil|
              custom_method association_schema['name'], config
            end
          end
        end

        private

        self.resource_definition = definition
      end
    end

    def self.generate_client_method(resource_name)
      method_name = resource_name.tableize
      resource_class = "::Syncano::Resources::#{resource_name}".constantize

      ::Syncano::API.send(:define_method, method_name) do
        ::Syncano::QueryBuilder.new(connection, resource_class)
      end
    end

    def self.extract_length_validation_options(attribute_definition)
      maximum = begin
        Integer attribute_definition['max_length']
      rescue TypeError, ArgumentError
      end

      { maximum: maximum } unless maximum.nil?
    end

    def self.extract_inclusion_validation_options(attribute_definition)
      return unless choices = attribute_definition['choices']

      { in: choices.map { |choice| choice['value'] } }
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
        datetime: ::DateTime,
        field: ::Object
      )

      type.present? ? mapping[type] : Object
    end

    def self.default_value_for_attribute(attribute)
      if attribute['type'].present? && attribute['type'].to_sym == :field
        {}
      else
        nil
      end
    end
  end
end