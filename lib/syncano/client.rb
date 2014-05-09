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

    # Proxy for new ::Syncano::Resources::Project object
    # @return [Syncano::Resources::Project]
    def projects
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Project)
    end

    # Proxy for new ::Syncano::Resources::Collection object
    # @param [Integer, String] project_id
    # @return [Syncano::Resources::Base]
    def collections(project_id)
      ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Collection, project_id: project_id)
    end

    # Performs request to Syncano api
    # @param [String] resource_name resource name in Syncano api
    # @param [String] method_name method name in Syncano api
    # @param [Hash] params additional params sent in the request
    # @return [Syncano::Response]
    def make_request(resource_name, method_name, params = {})
      response = client.send("#{resource_name}.#{method_name}", request_params.merge(params))
      parse_response(resource_name, response)
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
    # @return [Syncano::Response]
    def parse_response(resource_name, raw_response)
      status = raw_response.nil? || raw_response['result'] != 'NOK'
      data   = raw_response.nil? ? nil : raw_response[resource_name]
      errors = status ? [] : raw_response['error']

      ::Syncano::Response.new(status, data, errors)
    end
  end
end