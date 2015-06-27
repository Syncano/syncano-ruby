require 'dirty_hashy'

module Syncano
  module Resources
    class << self
      def build_definitions(schema_definition)
        schema_definition.map do |name, raw_resource_definition|
          ::Syncano::Schema::ResourceDefinition.new(name, raw_resource_definition)
          # resource_class = ::Syncano::Resources.define_resource_class(resource_definition)

          # if resource_definition[:collection].present? && resource_definition[:collection][:path].scan(/\{([^}]+)\}/).empty?
          #   self.class.generate_client_method(name, resource_class)
          # end
        end
      end

      def define_resource_class(resource_definition)
        resource_class = new_resource_class(resource_definition)

        const_set resource_definition.name, resource_class

        if resource_definition[:collection]
          resources_paths.collections.define resource_definition[:collection][:path], resource_class
        end

        if resource_definition[:member]
          resources_paths.members.define resource_definition[:member][:path], resource_class
        end

        resource_class
      end

      def resources_paths
        ::Syncano::Resources::Paths.instance
      end

      def new_resource_class(definition)
        attributes_definitions = definition.attributes

        ::Class.new(::Syncano::Resources::Base) do
          self.create_writable_attributes = []
          self.update_writable_attributes = []

          attributes_definitions.each do |attribute_definition|

            attribute attribute_definition.name,
                      type: attribute_definition.type,
                      default: attribute_definition.default

            # TODO extract to a dynamically defined module
            define_method("#{attribute_definition.name}=") do |new_value|
              if new_value != read_attribute(attribute_definition.name)
                send("#{attribute_definition.name}_will_change!")
              end

              super new_value
            end

            if attribute_definition.required?
              validates attribute_definition.name, presence: true
            end

            validates attribute_definition.name, length: attribute_definition.required_length

            if inclusion = attribute_definition.required_values_inclusion
              validates attribute_definition.name, inclusion: inclusion
            end

            self.create_writable_attributes << attribute_definition.name.to_sym if attribute_definition.writable?
            self.update_writable_attributes << attribute_definition.name.to_sym if attribute_definition.updatable?
          end


          if definition.name == 'Object' #TODO: extract to a separate module + spec
            def save(options = {})
              options.assert_valid_keys :overwrite
              overwrite = options[:overwrite] == true

              if new_record? || !overwrite
                super()
              else
                response = connection.request(:post, member_path, attributes)
                initialize! response, true
              end
            end

            def initialize!(_attributes = {}, _from_database = false)
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

    end
  end
end