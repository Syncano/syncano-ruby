class Syncano
  class QueryBuilder

    def initialize(client, resource_class, scope_parameters = {})
      self.client = client
      self.resource_class = resource_class
      self.scope_parameters = scope_parameters
    end

    def all
      resource_class.all(client, scope_parameters)
    end

    def first
      all.first
    end

    def last
      all.last
    end

    def find(id)
      resource_class.find(client, id, scope_parameters)
    end

    def find_by_key(key)
      resource_class.find_by_key(client, key, scope_parameters)
    end

    def new(attributes)
      resource_class.new(client, attributes.merge(scope_parameters))
    end

    def create(attributes)
      resource_class.create(client, attributes.merge(scope_parameters))
    end

    private

    attr_accessor :client, :resource_class, :scope_parameters
  end
end