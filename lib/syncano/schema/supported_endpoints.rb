module Syncano
  class Schema
    class SupportedEndpoints
      include Enumerable

      # TODO change to supported paths, whitelist
      UNSUPPORTED_PATHS = /\A\/v1\/(marketplace|paths)/

      def initialize(schema)
        @definition = schema.definition
      end

      def each(&block)
        defs = @definition.select { |_name, definition|
          definition[:collection] && definition[:collection][:path] !~ UNSUPPORTED_PATHS ||
            definition[:member] && definition[:member][:path] !~ UNSUPPORTED_PATHS
        }

        defs.each &block
      end
    end
  end
end