require 'syncano'
require 'mocha/api'

RSpec.configure do |config|
  config.mock_framework = :mocha
  config.before(:all) do
    @syncano_api_key = ENV['SYNCANO_API_KEY'] || raise('Set SYNCANO_API_KEY environment variable!')
    @syncano_instance_name = ENV['SYNCANO_INSTANCE_NAME'] || raise('Set SYNCANO_INSTANCE_NAME environment variable!')

    @client = ::Syncano.client({ instance_name: @syncano_instance_name, api_key: @syncano_api_key })
  end
end