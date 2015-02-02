module Syncano
  class QueryBuilder
    def initialize(connection, resource_class)
      self.connection = connection
      self.resource_class = resource_class
    end

    def all
      resource_class.all(connection)
    end

    def find(key = nil, conditions = {})
      resource_class.find(connection, key, conditions)
    end

    def new(attributes = {})
      resource_class.new(connection, attributes)
    end

    def create(attributes = {})
      resource_class.create(connection, attributes)
    end

    private

    attr_accessor :connection, :resource_class
  end
end