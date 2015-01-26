require 'faraday'
require 'syncano/version'
require 'syncano/api'
require 'syncano/connection'

module Syncano
  class Error < StandardError; end

  class ClientError < StandardError
    attr_accessor :body, :original_response

    def initialize(body, original_response)
      self.body = body
      self.original_response = original_response
    end
  end
end
