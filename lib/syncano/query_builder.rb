module Syncano
  class QueryBuilder
    def initialize(connection, resource_class)
      self.connection = connection
      self.resource_class = resource_class
    end

    def all(conditions)
      resource_class(all, conditions)
    end

    def find(key = nil, conditions = {})
      resource_class.find(client, key, conditions)
    end

    def new(attributes = {})
      resource_class.new(client, attributes)
    end

    def create(attributes)
      resource_class.create(client, attributes)
    end

    private

    attr_accessor :connection, :resource_class
  end
end