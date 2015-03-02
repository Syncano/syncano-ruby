module Syncano
  module Resources
    class Collection
      include Enumerable

      def self.from_database(response, scope, element_class)
        new response['objects'], scope, element_class, true
      end

      private

      attr_accessor :collection

      def initialize(collection, scope, element_class, from_database)
        self.collection = collection.map do |attributes|
          element_class.new scope.connection, scope.scope_parameters, attributes, true

        end
      end

      def each(&block)
        collection.each &block
      end
    end
  end
end
