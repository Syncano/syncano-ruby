class Syncano
  module Clients
    # Client used for communication with the JSON-RPC endpoint
    class Rest < Syncano::Clients::Base
      attr_accessor :client

      # Constructor for Syncano::Clients::Rest object
      # @param [String] instance_name
      # @param [String] api_key
      def initialize(instance_name, api_key)
        super(instance_name, api_key)
        self.client = ::Jimson::Client.new(json_rpc_url)
      end

      # Performs request to Syncano api
      # @param [String] resource_name
      # @param [String] method_name
      # @param [Hash] params additional params sent in the request
      # @param [String] response_key for cases when response from api is incompatible with the convention
      # @return [Syncano::Response]
      def make_request(resource_name, method_name, params = {}, response_key = nil)
        response_key ||= resource_name
        response = client.send("#{resource_name}.#{method_name}", request_params.merge(params))
        response = self.class.parse_response(response_key, response)

        response.errors.present? ? raise(Syncano::ApiError.new(response.errors)) : response
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
    end
  end
end