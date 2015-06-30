require 'celluloid'

module Syncano
  class Poller
    include Celluloid

    attr_accessor :connection, :method_name, :path, :responses

    def initialize(connection, method_name, path)
      self.connection = connection
      self.method_name = method_name
      self.path = path
      self.responses = []
    end

    def poll
      responses << connection.request(method_name, path)
    end

    def get_response
      responses.shift
    end
  end
end