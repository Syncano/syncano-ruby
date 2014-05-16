require "syncano/version"

class Syncano

  # Used for initializing Syncano Client
  # @param [Hash] options with keys: instance_name, api_key which can be also provided as constants in the initializer
  # @return [Syncano::Client] Syncano client.
  def self.client(options = {})
    instance_name = options[:instance_name] || ::SYNCANO_INSTANCE_NAME
    raise 'Syncano instance name cannot be blank!' if instance_name.nil?

    api_key = options[:api_key] || ::SYNCANO_API_KEY
    raise 'Syncano api key cannot be blank!' if api_key.nil?

    Syncano::Client.new(instance_name, api_key)
  end
end

require 'jimson/client'
require 'syncano/jimson_client'
require 'multi_json'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/class/attribute.rb'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/json/decoding.rb'
require 'active_support/json/encoding.rb'
require 'active_support/time_with_zone.rb'
require 'syncano/errors'
require 'syncano/client'
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
require 'syncano/resources/user'