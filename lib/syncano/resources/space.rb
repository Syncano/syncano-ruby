module Syncano
  module Resources
    class Space
      attr_accessor :at, :query_builder

      def initialize(at, query_builder, options = {})
        self.at = at
        self.query_builder = query_builder
      end

      def all
        query_builder.all(last_pk: at.primary_key, direction: 1)
      end
    end
  end
end
