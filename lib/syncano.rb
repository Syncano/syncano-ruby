$: << Dir.pwd

require 'active_attr'
require 'active_model'
require 'active_support/concern'
require 'active_support/core_ext/class/attribute.rb'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/inflector'
require 'celluloid/future'
require 'celluloid/io'
require 'faraday'
require 'http'

require 'syncano/query_builder'
require 'syncano/version'
require 'syncano/api'
require 'syncano/api/endpoints'
require 'syncano/connection'
require 'syncano/schema'
require 'syncano/scope'
require 'syncano/poller'
require 'syncano/resources'
require 'syncano/resources/base'
require 'syncano/resources/collection'
require 'syncano/resources/paths'
require 'syncano/resources/space'
require 'syncano/response'
require 'syncano/query_builder'

module Syncano
  class << self
    def connect(options = {})
      connection = Connection.new(
          options.reverse_merge(api_key: ENV['SYNCANO_API_KEY']))
      connection.authenticate unless connection.authenticated?

      API.new connection
    end
  end

  class Error < StandardError; end

  class RuntimeError < StandardError; end

  class HTTPError < StandardError
  end

  class NotFound < HTTPError
    attr_accessor :path, :method_name

    def initialize(path, method_name)
      self.path = path
      self.method_name = method_name
    end

    def inspect
      %{#{self.class.name} path: "#{path}" method: "#{method_name}"}
    end
  end

  class HTTPErrorWithBody < HTTPError

    attr_accessor :body, :original_response

    def initialize(body, original_response)
      self.body = body
      self.original_response = original_response
    end

    def inspect
      "<#{self.class.name} #{body} #{original_response}>"
    end

    alias :to_s :inspect
  end

  class ClientError < HTTPErrorWithBody; end
  class ServerError < HTTPErrorWithBody; end

  class UnsupportedStatusError < StandardError
    attr_accessor :original_response

    def initialize(original_response)
      self.original_response = original_response
    end

    def inspect
      "The server returned unsupported status code #{original_response.status}"
    end
  end
end