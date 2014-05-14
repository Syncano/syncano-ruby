class Syncano
  class QueryBuilder

    def initialize(client, resource_class, scope_parameters = {})
      self.client = client
      self.resource_class = resource_class
      self.scope_parameters = scope_parameters
    end

    def batch
      ::Syncano::BatchQueueElement.new(self)
    end

    def all(conditions = {})
      resource_class.all(client, conditions.merge(scope_parameters))
    end

    def count(conditions = {})
      resource_class.count(client, conditions.merge(scope_parameters))
    end

    def first(conditions = {})
      all(conditions).first
    end

    def last(conditions = {})
      all(conditions).last
    end

    def find(id, conditions = {})
      resource_class.find(client, id, scope_parameters, conditions)
    end

    def find_by_key(key, conditions = {})
      resource_class.find_by_key(client, key, scope_parameters, conditions)
    end

    def find_by_name(name, conditions = {})
      resource_class.find_by_name(client, name, scope_parameters, conditions)
    end

    def find_by_email(email, conditions = {})
      resource_class.find_by_email(client, email, scope_parameters, conditions)
    end

    def new(attributes = {})
      resource_class.new(client, attributes.merge(scope_parameters))
    end

    def create(attributes)
      resource_class.create(client, attributes.merge(scope_parameters))
    end

    def batch_create(batch_client, attributes)
      resource_class.batch_create(batch_client, client, attributes.merge(scope_parameters))
    end

    def copy(ids)
      resource_class.copy(client, scope_parameters, ids)
    end

    def batch_copy(batch_client, ids)
      resource_class.batch_copy(batch_client, scope_parameters, ids)
    end

    def move(ids, conditions = {}, new_folder = nil, new_state = nil)
      resource_class.move(client, scope_parameters, ids, conditions = {}, new_folder = nil, new_state = nil)
    end

    def batch_move(batch_client, ids, conditions = {}, new_folder = nil, new_state = nil)
      resource_class.batch_move(batch_client, scope_parameters, ids, conditions = {}, new_folder = nil, new_state = nil)
    end

    private

    attr_accessor :client, :resource_class, :scope_parameters
  end
end