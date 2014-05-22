# Overwritten module from Jimson gem
module Jimson
  # Overwritten helper from Jimson gem
  class ClientHelper
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