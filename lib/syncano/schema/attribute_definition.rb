module Syncano
  class Schema
    class AttributeDefinition
      attr_accessor :name, :type, :default

      TYPES_MAPPING = { 'string' => ::String,
                        'email' => ::String,
                        'choice' => ::String,
                        'slug' => ::String,
                        'integer' => ::Integer,
                        'float' => ::Float,
                        'date' => ::Date,
                        'datetime' => ::DateTime,
                        'field' => ::Object }

      def initialize(name, raw_definition)
        # TODO implement #original_name to send request with correct parameters
        self.name = name == 'class' ? 'associated_class' : name
        self.raw_definition = raw_definition

        set_type
        set_default
      end

      def writable?
        raw_definition['read_only'] == false
      end

      def required?
        raw_definition['required'] == true
      end

      def required_length
        begin
          { maximum: Integer(raw_definition['max_length']) }
        rescue TypeError, ArgumentError
        end
      end

      def required_values_inclusion
        return unless choices = raw_definition['choices']

        { in: choices.map { |choice| choice['value'] } }
      end

      alias :updatable? :writable?

      def [](key)
        raw_definition[key]
      end

      private

      attr_accessor :raw_definition

      def set_type
        self.type = if %w[owner group].include?(name)
                      ::Integer
                    elsif raw_definition['type'].blank?
                      ::Object
                    else
                      TYPES_MAPPING[raw_definition['type']]
                    end
      end

      def set_default
        # TODO temporary workaround
        raw_definition.merge! raw_definition['type'] if raw_definition['type'].is_a?(Hash)

        self.default = if name == 'channel'
                         nil
                       elsif raw_definition['type'].present? && raw_definition['type'].to_sym == :field
                         {}
                       elsif raw_definition['type'].present? && raw_definition['type'].to_sym == :choice
                          raw_definition['choices'].first['value']
                       else
                         nil
                       end
      end
    end
  end
end
