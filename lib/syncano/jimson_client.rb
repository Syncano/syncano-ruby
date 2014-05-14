module Jimson
  class ClientHelper
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

  class Request
    def as_json(options = {})
      to_h
    end
  end
end