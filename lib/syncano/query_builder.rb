class Syncano
  # Proxy class for creating proper requests to api through ActiveRecord pattern
  class QueryBuilder
    # Constructor for Syncano::QueryBuilder object
    # @param [Syncano::Clients::Base] client
    # @param [String] resource_class
    # @param [Hash] scope_parameters
    def initialize(client, resource_class, scope_parameters = {})
      self.client = client
      self.resource_class = resource_class
      self.scope_parameters = scope_parameters
    end

    # Proxy for preparing batch requests
    # ie. query_builder.batch.create will prepare BatchQueueElement
    # which invokes batch_create method on query builder object
    # @return [Syncano::BatchQueueElement]
    def batch
      ::Syncano::BatchQueueElement.new(self)
    end

    # Proxy for calling "all" method on the resource object
    # @param [Hash] conditions
    # @return [Array] collection of Syncano::Resources::Base objects
    def all(conditions = {})
      resource_class.all(client, conditions.merge(scope_parameters))
    end

    # Proxy for calling "count" method on the resource object
    # @param [Hash] conditions
    # @return [Integer]
    def count(conditions = {})
      resource_class.count(client, conditions.merge(scope_parameters))
    end

    # Returns first element from all returned by "all" method
    # @param [Hash] conditions
    # @return [Syncano::Resources::Base]
    def first(conditions = {})
      all(conditions).first
    end

    # Returns last element from all returned by "all" method
    # @param [Hash] conditions
    # @return [Syncano::Resources::Base]
    def last(conditions = {})
      all(conditions).last
    end

    # Proxy for calling "find" method on the resource object
    # @param [Integer, String] key
    # @param [Hash] conditions
    # @return [Syncano::Resources::Base]
    def find(key = nil, conditions = {})
      resource_class.find(client, key, scope_parameters, conditions)
    end

    # Proxy for calling "find_by_key" method on the resource object
    # @param [String] key
    # @param [Hash] conditions
    # @return [Syncano::Resources::Base]
    def find_by_key(key, conditions = {})
      resource_class.find_by_key(client, key, scope_parameters, conditions)
    end

    # Proxy for calling "find_by_name" method on the resource object
    # @param [String] name
    # @param [Hash] conditions
    # @return [Syncano::Resources::Base]
    def find_by_name(name, conditions = {})
      resource_class.find_by_name(client, name, scope_parameters, conditions)
    end

    # Proxy for calling "find_by_email" method on the resource object
    # @param [String] email
    # @param [Hash] conditions
    # @return [Syncano::Resources::Base]
    def find_by_email(email, conditions = {})
      resource_class.find_by_email(client, email, scope_parameters, conditions)
    end

    # Proxy for calling "new" method on the resource object
    # @param [Hash] attributes
    # @return [Syncano::Resources::Base]
    def new(attributes = {})
      resource_class.new(client, attributes.merge(scope_parameters))
    end

    # Proxy for calling "create" method on the resource object
    # @param [Hash] attributes
    # @return [Syncano::Resources::Base]
    def create(attributes)
      resource_class.create(client, attributes.merge(scope_parameters))
    end

    # Proxy for calling "batch_create" method on the resource object
    # @param [Jimson::Client] batch_client
    # @param [Hash] attributes
    # @return [Syncano::Response]
    def batch_create(batch_client, attributes)
      resource_class.batch_create(batch_client, client, attributes.merge(scope_parameters))
    end

    # Proxy for calling "copy" method on the resource object
    # @param [Array] ids
    # @return [Array] collection of Syncano::Resource objects
    def copy(ids)
      resource_class.copy(client, scope_parameters, ids)
    end

    # Proxy for calling "batch_copy" method on the resource object
    # @param [Jimson::Client] batch_client
    # @param [Array] ids
    # @return [Syncano::Response]
    def batch_copy(batch_client, ids)
      resource_class.batch_copy(batch_client, scope_parameters, ids)
    end

    # Proxy for calling "move" method on the resource object
    # @param [Array] ids
    # @param [Hash] conditions
    # @param [String] new_folder
    # @param [String] new_state
    # @return [Array] collection of Syncano::Resource objects
    def move(ids, conditions = {}, new_folder = nil, new_state = nil)
      resource_class.move(client, scope_parameters, ids, conditions, new_folder, new_state)
    end

    # Proxy for calling "batch_move" method on the resource object
    # @param [Jimson::Client] batch_client
    # @param [Array] ids
    # @param [Hash] conditions
    # @param [String] new_folder
    # @param [String] new_state
    # @return [Syncano::Response]
    def batch_move(batch_client, ids, conditions = {}, new_folder = nil, new_state = nil)
      resource_class.batch_move(batch_client, scope_parameters, ids, conditions, new_folder, new_state)
    end

    # Proxy for calling "login" method on the resource object
    # @param [String] username
    # @param [String] password
    # @return [Array] collection of Syncano::Resource objects
    def login(username = nil, password = nil)
      resource_class.login(client, username, password)
    end

    private

    attr_accessor :client, :resource_class, :scope_parameters
  end
end