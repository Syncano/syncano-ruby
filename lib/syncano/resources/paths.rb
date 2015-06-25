require 'singleton'

module Syncano
  module Resources
    class Paths
      include Singleton

      attr_accessor :collections, :members

      def initialize
        self.collections = self.class::Collection.new
        self.members = self.class::Member.new
      end

      private

      class Collection
        def initialize
          @map = {}
        end

        def define(path, resource)
          @map[Regexp.new("\\A#{path.gsub(/{[^}]*}/, '([^\/]+)')}\\z")] = resource
        end

        def match(path)
          _, resouce = @map.find { |pattern, _| pattern =~ path }
          resouce
        end
      end

      class Member
        def initialize
          @map = {}
        end

        def define(path, resource)
          resource_name = resource.name
          # raise 'duplicated resource' if @map.has_key?(resource_name)
          @map[resource_name] = path
        end

        def find(resource)
          @map[resource.name]
        end
      end
    end
  end
end