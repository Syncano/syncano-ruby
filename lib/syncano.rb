require "syncano/version"

class Syncano

  # Used for initializing Syncano Client
  # @param [Hash] options with keys: instance_name, api_key which can be also provided as constants in the initializer
  # @return [Syncano::Client] Syncano client.
  def self.client(options = {})
    auth_data = self.auth_data
    Syncano::Clients::Rest.new(auth_data[:instance_name], auth_data[:api_key])
  end

  def self.sync_client(options = {})
    auth_data = self.auth_data
    client = Syncano::Clients::Sync.instance(auth_data[:instance_name], auth_data[:api_key])
    client.connect
    client
  end

  private

  def self.auth_data(options = {})
    instance_name = options[:instance_name] || ::SYNCANO_INSTANCE_NAME
    raise 'Syncano instance name cannot be blank!' if instance_name.nil?

    api_key = options[:api_key] || ::SYNCANO_API_KEY
    raise 'Syncano api key cannot be blank!' if api_key.nil?

    { instance_name: instance_name, api_key: api_key }
  end
end

require 'jimson/client'
require 'syncano/jimson_client'
require 'eventmachine'
require 'multi_json'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/class/attribute.rb'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/json/decoding.rb'
require 'active_support/json/encoding.rb'
require 'active_support/time_with_zone.rb'
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