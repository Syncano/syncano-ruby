$: << Dir.pwd

require 'faraday'
require 'active_attr/model'
require 'active_attr/dirty'
require 'active_attr/typecasting_override'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/class/attribute.rb'
require 'active_support/inflector'
require 'syncano/version'
require 'syncano/api'
require 'syncano/connection'
require 'syncano/schema'
require 'syncano/scope'
require 'syncano/resources'
require 'syncano/resources/base'
require 'syncano/resources/collection'
require 'syncano/resources/space'
require 'syncano/query_builder'
require 'syncano/model/base'

module Syncano
  class << self
    def connect(options = {})
      connection = Connection.new(
          options.reverse_merge(api_key: ENV['SYNCANO_API_KEY']))
      connection.authenticate! unless connection.authenticated?

      API.new connection
    end
  end

  class Error < StandardError; end

  class RuntimeError < StandardError; end

  class HTTPError < StandardError
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

  class ClientError < HTTPError; end
  class ServerError < HTTPError; end

  class UnsupportedStatusError < StandardError
    attr_accessor :original_response

    def initialize(original_response)
      self.original_response = original_response
    end

    def inspect
      "The server returned unsupported status code #{original_response.status}"
    end

    alias :to_s :inspect
  end
end