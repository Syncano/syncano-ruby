class Syncano
  module Resources
  end

  class Client
    attr_accessor :instance_name, :api_key, :client

    def initialize(instance_name, api_key)
      super()

      self.instance_name = instance_name
      self.api_key = api_key
      self.client = ::Jimson::Client.new(json_rpc_url)
    end

    def project
      ::Syncano::Resources::Project.new(self)
    end

    def make_request(resource_name, method_name, params = {})
      response = client.send("#{resource_name}.#{method_name}", request_params.merge(params))
      parse_response(resource_name, response)
    end

    private

    def json_rpc_url
      "https://#{instance_name}.syncano.com/api/jsonrpc"
    end

    def request_params
      { api_key: api_key }
    end

    def parse_response(resource_name, response)
      return response if response.blank?

      if response['result'] == 'OK'
        response[resource_name]
      else
        # TODO: Error handling
        { 'error' => 'Something went wrong' }
      end
    end
  end
end