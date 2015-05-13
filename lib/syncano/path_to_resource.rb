require 'singleton'

module Syncano
  class PathToResource
    include Singleton

    attr_accessor :collection

    def initialize
      self.collection = self.class::Collection.new
    end

    private

    class Collection < Hash
      def initialize
        @map = {}
      end

      def []=(path, resource)
        @map[Regexp.new("\\A#{path.gsub(/{\w+(_\w+)}/, '([^\/]+)')}\\z")] = resource
      end

      def [](path)
        _, resouce = @map.find { |pattern, _| pattern =~ path }
        resouce
      end
    end
  end
end