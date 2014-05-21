class Syncano
  module Clients
    class Rest < Syncano::Clients::Base
      attr_accessor :client

      def initialize(instance_name, api_key)
        super(instance_name, api_key)
        self.client = ::Jimson::Client.new(json_rpc_url)
      end

      # Performs request to Syncano api
      # @param [String] resource_name
      # @param [String] method_name
      # @param [Hash] params additional params sent in the request
      # @return [Syncano::Response]
      def make_request(resource_name, method_name, params = {})
        response = client.send("#{resource_name}.#{method_name}", request_params.merge(params))
        response = self.class.parse_response(resource_name, response)

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