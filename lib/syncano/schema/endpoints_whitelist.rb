module Syncano
  class Schema
    class EndpointsWhitelist
      include Enumerable

      class SupportedDefinitionPredicate
        attr_accessor :definition

        def initialize(definition)
          self.definition = definition
        end

        def call
          path =~ /\A\/v1\/instances/ && path !~ /invitation/
        end

        private

        def path
          definition[:collection] && definition[:collection][:path] ||
            definition[:member] && definition[:member][:path]
        end
      end

      SUPPORTED_DEFINITIONS = -> (definition) {
        SupportedDefinitionPredicate.new(definition).call
      }

      def initialize(schema)
        @definition = schema.definition
      end

      def each(&block)
        @definition.select { |_name, definition|
          SUPPORTED_DEFINITIONS === definition
        }.each &block
      end
    end
  end
end