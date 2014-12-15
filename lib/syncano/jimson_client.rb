# Overwritten module from Jimson gem
module Jimson
  # Overwritten helper from Jimson gem
  class ClientHelper
    # Overwritten send_single_request method, so it now adds header with the user agent
    # @return [Array] collection of responses
    def send_single_request(method, args)
      post_data = {
          'jsonrpc' => JSON_RPC_VERSION,
          'method'  => method,
          'params'  => args,
          'id'      => self.class.make_id
      }.to_json
      resp = RestClient.post(@url, post_data, content_type: 'application/json', user_agent: "syncano-ruby-#{Syncano::VERSION}")
      if resp.nil? || resp.body.nil? || resp.body.empty?
        raise Jimson::ClientError::InvalidResponse.new
      end

      return resp.body

    rescue Exception, StandardError
      raise Jimson::ClientError::InternalError.new($!)
    end

    # Overwritten send_batch_request method, so it now adds header with the user agent
    # @return [Array] collection of responses
    def send_batch_request(batch)
      post_data = batch.to_json
      resp = RestClient.post(@url, post_data, content_type: 'application/json', user_agent: "syncano-ruby-#{Syncano::VERSION}")
      if resp.nil? || resp.body.nil? || resp.body.empty?
        raise Jimson::ClientError::InvalidResponse.new
      end

      return resp.body
    end

    # Overwritten send_batch method, so it now returns collection of responses
    # @return [Array] collection of responses
    def send_batch
      batch = @batch.map(&:first) # get the requests
      response = send_batch_request(batch)

      begin
        responses = JSON.parse(response)
      rescue
        raise Jimson::ClientError::InvalidJSON.new(json)
      end

      process_batch_response(responses)
      responses = @batch

      @batch = []

      responses
    end
  end

  # Overwritten Request class from Jimson gem
  class Request
    # Overwritten as_json method which solves bug with serialization batch requests
    # @return [Hash]
    def as_json(options = {})
      to_h
    end
  end
end