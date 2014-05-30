require 'syncano/version'

# Main class used for instantizing clients and as scope for other classes
class Syncano
  # Used for initializing Syncano Rest Client
  # @param [Hash] options with keys: instance_name, api_key which can be also provided as constants in the initializer
  # @return [Syncano::Clients::Rest] Syncano client.
  def self.client(options = {})
    auth_data = self.auth_data(options)
    client = Syncano::Clients::Rest.new(auth_data[:instance_name], auth_data[:api_key], auth_data[:auth_key])
    client.login(options[:username], options[:password]) if client.auth_key.nil? && options[:username].present?
    client
  end

  # Used for initializing Syncano Sync Client
  # @param [Hash] options with keys: instance_name, api_key which can be also provided as constants in the initializer
  # @return [Syncano::Clients::Rest] Syncano client.
  def self.sync_client(options = {})
    auth_data = self.auth_data(options)
    client = Syncano::Clients::Sync.instance(auth_data[:instance_name], auth_data[:api_key], auth_data[:auth_key])
    client.login(options[:username], options[:password]) if client.auth_key.nil? && options[:username].present?
    client.connect
    client
  end

  private

  # Prepares hash with auth data from options or constants in initializer
  # @param [Hash] options with keys: instance_name, api_key which can be also provided as constants in the initializer
  # @return [Hash]
  def self.auth_data(options = {})
    instance_name = options[:instance_name] || ::SYNCANO_INSTANCE_NAME
    raise 'Syncano instance name cannot be blank!' if instance_name.nil?

    api_key = options[:api_key] || ::SYNCANO_API_KEY
    raise 'Syncano api key cannot be blank!' if api_key.nil?

    { instance_name: instance_name, api_key: api_key, auth_key: options[:auth_key] }
  end
end

# Jimson client
require 'jimson/client'
require 'syncano/jimson_client'

# Multi Json
require 'multi_json'

# Eventmachine
require 'eventmachine'

# Singleton
require 'singleton'

# ActiveSupport
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/class/attribute.rb'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/json/decoding.rb'
require 'active_support/json/encoding.rb'
require 'active_support/time_with_zone.rb'

# Syncano
require 'syncano/errors'
require 'syncano/clients/base'
require 'syncano/clients/rest'
require 'syncano/clients/sync'
require 'syncano/sync_connection'
require 'syncano/query_builder'
require 'syncano/batch_queue'
require 'syncano/batch_queue_element'
require 'syncano/response'
require 'syncano/resources/base'
require 'syncano/resources/admin'
require 'syncano/resources/api_key'
require 'syncano/resources/data_object'
require 'syncano/resources/collection'
require 'syncano/resources/folder'
require 'syncano/resources/project'
require 'syncano/resources/role'
require 'syncano/resources/subscription'
require 'syncano/resources/user'
require 'syncano/packets/base'
require 'syncano/packets/auth'
require 'syncano/packets/call'
require 'syncano/packets/call_response'
require 'syncano/packets/error'
require 'syncano/packets/message'
require 'syncano/packets/notification'
require 'syncano/packets/ping'
require 'syncano/resources/notifications/base'
require 'syncano/resources/notifications/create'
require 'syncano/resources/notifications/update'
require 'syncano/resources/notifications/destroy'
require 'syncano/resources/notifications/message'