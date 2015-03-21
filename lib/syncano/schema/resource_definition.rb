module Syncano
  class Schema
    class ResourceDefinition
      attr_accessor :attributes

      def initialize(raw_defitnition)
        @raw_definition = raw_defitnition

        self.attributes = raw_defitnition[:attributes].map do |name, raw_attribute_definition|
          AttributeDefinition.new name, raw_attribute_definition
        end
      end

      def [](key)
        @raw_definition[key]
      end
    end
  end
end