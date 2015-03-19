module Syncano
  module Resources
    class Collection
      include Enumerable

      delegate :last, :[], to: :collection

      def self.from_database(response, scope, element_class)
        new response, scope, element_class, true
      end

      def each(&block)
        collection.each &block
      end

      def prev?
        @prev
      end

      def next?
        @next
      end

      private

      attr_accessor :collection

      def initialize(response, scope, element_class, from_database)
        @prev, @next = response['prev'].present?, response['next'].present?
        self.collection = response['objects'].map do |attributes|
          element_class.new scope.connection, scope.scope_parameters, attributes, from_database
        end
      end
    end
  end
end
