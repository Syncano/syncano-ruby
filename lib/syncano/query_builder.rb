module Syncano
  class QueryBuilder
    def initialize(connection, resource_class, scope_parameters = {})
      self.connection = connection
      self.resource_class = resource_class
      self.scope_parameters = scope_parameters
    end

    def all(filter_attributes = {})
      resource_class.all(connection, scope_parameters, filter_attributes)
    end

    def first
      resource_class.first(connection, scope_parameters)
    end

    def last
      resource_class.last(connection, scope_parameters)
    end

    def find(key = nil)
      resource_class.find(connection, scope_parameters, key)
    end

    def new(attributes = {})
      resource_class.new(connection, scope_parameters, attributes)
    end

    def create(attributes = {})
      resource_class.create(connection, scope_parameters, attributes)
    end

    def space(at, options = {})
      Syncano::Resources::Space.new(at, self, options)
    end

    private

    attr_accessor :connection, :resource_class, :scope_parameters
  end
end
