require "syncano/version"

class Syncano

  def self.client(options = {})
    instance_name = options[:instance_name] || ::SYNCANO_INSTANCE_NAME
    raise 'Syncano instance name cannot be blank!' if instance_name.nil?

    api_key = options[:api_key] || ::SYNCANO_API_KEY
    raise 'Syncano api key cannot be blank!' if api_key.nil?

    Syncano::Client.new(instance_name, api_key)
  end
end

require 'jimson/client'
require 'syncano/client'
require 'syncano/resources/base'
require 'syncano/resources/project'