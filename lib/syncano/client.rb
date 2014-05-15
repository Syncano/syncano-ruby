class Syncano
  module Resources
  end

  class Client
    attr_accessor :instance_name, :api_key, :client

    # Constructor for Syncano::Client object
    # @param [String] instance_name
    # @param [String] api_key
    def initialize(instance_name, api_key)
      super()

      self.instance_name = instance_name
      self.api_key = api_key
      self.client = ::Jimson::Client.new(json_rpc_url)
    end

    # Returns query builder for Syncano::Resources::Admin objects
    # @return [Syncano::QueryBuilder]
    def admins
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Admin)
    end

    # Returns query builder for Syncano::Resources::ApiKey objects
    # @return [Syncano::QueryBuilder]
    def api_keys
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::ApiKey)
    end

    # Returns query builder for Syncano::Resources::Role objects
    # @return [Syncano::QueryBuilder]
    def roles
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Role)
    end

    # Returns query builder for Syncano::Resources::Project objects
    # @return [Syncano::QueryBuilder]
    def projects
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Project)
    end

    # Returns query builder for Syncano::Resources::Project objects
    # @param [Integer, String] project_id
    # @return [Syncano::QueryBuilder]
    def collections(project_id)
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Collection, project_id: project_id)
    end

    # Returns query builder for Syncano::Resources::Folder objects
    # @param [Integer, String] project_id
    # @param [Integer, String] collection_id
    # @return [Syncano::QueryBuilder]
    def folders(project_id, collection_id)
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Collection, project_id: project_id, collection_id: collection_id)
    end

    # Returns query builder for Syncano::Resources::DataObject objects
    # @param [Integer, String] project_id
    # @param [Integer, String] collection_id
    # @return [Syncano::QueryBuilder]
    def data_objects(project_id, collection_id)
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::DataObject, project_id: project_id, collection_id: collection_id)
    end

    # Returns query builder for Syncano::Resources::User objects
    # @param [Integer, String] project_id
    # @param [Integer, String] collection_id
    # @return [Syncano::QueryBuilder]
    def users(project_id, collection_id)
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::User, project_id: project_id, collection_id: collection_id)
    end

    # Performs request to Syncano api
    # @param [String] resource_name
    # @param [String] method_name
    # @param [Hash] params additional params sent in the request
    # @return [Syncano::Response]
    def make_request(resource_name, method_name, params = {})
      response = client.send("#{resource_name}.#{method_name}", request_params.merge(params))
      response = self.class.parse_response(resource_name, response)

      response.errors.present? ? raise(Syncano::ApiError.new(errors)) : response
    end

    # Performs batch request to Syncano api
    # @param [Jimson::BatchClient] batch_client
    # @param [String] resource_name
    # @param [String] method_name
    # @param [Hash] params additional params sent in the request
    def make_batch_request(batch_client, resource_name, method_name, params = {})
      batch_client.send("#{resource_name}.#{method_name}", request_params.merge(params))
    end

    # Gets block in which Syncano::BatchQueue object is provided and batch requests can be executed
    # @param [Block]
    # @return [Array] collection of parsed responses
    def batch
      queue = ::Syncano::BatchQueue.new(client)
      yield(queue)
      queue.prune!

      queue.responses.collect do |response|
        resource_name = response.first.method.split('.').first
        self.class.parse_response(resource_name, response.last.result)
      end
    end

    private

    # Generates url to json rpc api
    # @return [String]
    def json_rpc_url
      "https://#{instance_name}.syncano.com/api/jsonrpc"
    end

    # Prepares hash with default request params
    # @return [Hash]
    def request_params
      { api_key: api_key }
    end

    # Parses Syncano api response and returns Syncano::Response object
    # @param [String] resource_name
    # @param [Hash] raw_response
    # @return [Syncano::Response]
    def self.parse_response(resource_name, raw_response)
      status = raw_response.nil? || raw_response['result'] != 'NOK'
      if raw_response.nil?
        data = nil
      elsif raw_response[resource_name].present?
        data = raw_response[resource_name]
      else
        data = raw_response['count']
      end
      errors = status ? [] : raw_response['error']

      ::Syncano::Response.new(status, data, errors)
    end
  end
end