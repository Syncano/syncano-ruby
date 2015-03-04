module Syncano
  module Resources
    class Space

      DEFAULT_DIRECTION = :next
      DIRECTIONS = { DEFAULT_DIRECTION => 1, :prev => 0 }
      DIRECTIONS.default_proc = ->(hash, key) do
        if key.nil?
          hash[DEFAULT_DIRECTION]
        else
          raise Syncano::RuntimeError.new("Valid orders are #{hash.keys}, you passed #{key.inspect}")
        end
      end
      DIRECTIONS.freeze

      attr_accessor :at, :query_builder, :direction

      def initialize(at, query_builder, options = {})
        self.at = at
        self.query_builder = query_builder
        self.direction = DIRECTIONS[options[:direction]]
      end

      def all
        query_builder.all last_pk: at.primary_key, direction: direction
      end
    end
  end
end
