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
require 'syncano/resources/base'
require 'syncano/resources/collection'
require 'syncano/resources/space'
require 'syncano/query_builder'
require 'syncano/model/base'

module Syncano
  class << self
    def connect(options = {})
      connection = Connection.new(options)
      connection.authenticate! unless connection.authenticated?

      API.new connection
    end
  end

  class Error < StandardError; end

  class RuntimeError < StandardError; end

  class ClientError < StandardError
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
end