require 'celluloid/io'
require 'http'

module Syncano
  class Poller
    attr_accessor :connection, :method_name, :path, :responses

    def initialize(connection, method_name, path)
      self.connection = connection
      self.method_name = method_name
      self.path = path
      self.responses = []
    end

    def poll
      responses << connection.http_fetcher.get(path)
    end

    def get_response
      responses.shift
    end
  end
end