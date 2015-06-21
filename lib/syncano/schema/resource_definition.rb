module Syncano
  class Schema
    class ResourceDefinition
      attr_accessor :attributes
      attr_accessor :name

      def initialize(name, raw_defitnition)
        @raw_definition = raw_defitnition

        delete_colliding_links

        self.name = name

        self.attributes = raw_defitnition[:attributes].map do |name, raw_attribute_definition|
          Syncano::Schema::AttributeDefinition.new name, raw_attribute_definition
        end
      end

      def [](key)
        @raw_definition[key]
      end

      def top_level?
        @raw_definition[:collection].present? &&
          @raw_definition[:collection][:path].scan(/\{([^}]+)\}/).empty?
      end

      private

      def delete_colliding_links
        @raw_definition[:attributes].each do |k, v|
          if @raw_definition[:associations]['links']
            @raw_definition[:associations]['links'].delete_if do |link|
              link['name'] == k
            end
          end
        end
      end
    end
  end
end