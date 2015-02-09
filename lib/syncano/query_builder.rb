module Syncano
  class QueryBuilder
    def initialize(connection, resource_class, scope_parameters = {})
      self.connection = connection
      self.resource_class = resource_class
      self.scope_parameters = scope_parameters
    end

    def all
      resource_class.all(connection, scope_parameters)
    end

    def find(key = nil)
      resource_class.find(connection, key, scope_parameters)
    end

    def new(attributes = {})
      resource_class.new(connection, attributes)
    end

    def create(attributes = {})
      resource_class.create(connection, attributes)
    end

    private

    attr_accessor :connection, :resource_class, :scope_parameters
  end
end