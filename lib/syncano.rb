require 'faraday'
require 'active_attr/model'
require 'active_attr/dirty'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/class/attribute.rb'
require 'active_support/inflector'
require 'syncano/version'
require 'syncano/api'
require 'syncano/connection'
require 'syncano/schema'
require 'syncano/resources/base'
require 'syncano/query_builder'

module Syncano
  class << self
    def connect(options = {})
      connection = Connection.new(options)
      connection.authenticate! unless connection.authenticated?

      API.new connection
    end
  end

  class Error < StandardError; end

  class ClientError < StandardError
    attr_accessor :body, :original_response

    def initialize(body, original_response)
      self.body = body
      self.original_response = original_response
    end
  end
end