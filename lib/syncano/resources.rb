require 'dirty_hashy'

module Syncano
  module Resources
    class << self
      def define_resource(name, resource_definition)
        const_set name, new_resource_class(resource_definition, name)
      end

      def new_resource_class(definition, name)
        attributes_definitions = []

        definition[:attributes].each do |attribute_name, attribute|
          attributes_definitions << {
              name: attribute_name,
              type: map_syncano_attribute_type(attribute['type'], attribute_name),
              default: attribute_name == 'channel' ? nil : default_value_for_attribute(attribute),
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


          if name == 'Object' #TODO: extract to a separate module + spec
            def initialize!(_attributes, _from_database)
              to_return = super

              custom_attributes.clean_up!

              to_return
            end

            def select_changed_attributes
              custom_attributes.changes.inject(super) do |changed, (key, (_was, is))|
                changed[key] = is
                changed
              end
            end

            def attributes=(new_attributes)
              super

              self.custom_attributes = new_attributes.select { |k, v| !self.class.attributes.keys.include?(k) }
            end

            def attributes
              super.merge custom_attributes
            end

            def changed
              super + custom_attributes.changes.keys
            end

            def custom_attributes
              @custom_attributes ||= DirtyHashy.new
            end

            def custom_attributes=(value)
              @custom_attributes = value.is_a?(DirtyHashy) ?
                value : DirtyHashy.new(value)
            end

            def method_missing(method_name, *args, &block)
              if method_name.to_s =~ /=$/
                custom_attributes[method_name.to_s.gsub(/=$/, '')] = args.first
              else
                if custom_attributes.has_key? method_name.to_s
                  custom_attributes[method_name.to_s]
                else
                  super
                end
              end
            end
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

      def extract_length_validation_options(attribute_definition)
        maximum = begin
          Integer attribute_definition['max_length']
        rescue TypeError, ArgumentError
        end

        { maximum: maximum } unless maximum.nil?
      end

      def extract_inclusion_validation_options(attribute_definition)
        return unless choices = attribute_definition['choices']

        { in: choices.map { |choice| choice['value'] } }
      end

      def map_syncano_attribute_type(type, name)
        return ::Integer if %w[owner group].include? name

        mapping = HashWithIndifferentAccess.new(
          string: ::String,
          email: ::String,
          choice: ::String,
          slug: ::String,
          integer: ::Integer,
          float: ::Float,
          date: ::Date,
          datetime: ::DateTime,
          field: ::Object)

        type.present? ? mapping[type] : Object
      end

      def default_value_for_attribute(attribute)
        if attribute['type'].present? && attribute['type'].to_sym == :field
          {}
        elsif attribute['type'].present? && attribute['type'].to_sym == :choice
          attribute['choices'].first['value']
        else
          nil
        end
      end
    end
  end
end