require 'bundler'
Bundler.setup

require 'dotenv'
Dotenv.load

require 'rspec-prof' if ENV['SPEC_PROFILE']
require 'syncano'
require 'webmock/rspec'
require 'celluloid/test'

WebMock.disable_net_connect!

def generate_body(params)
  JSON.generate(params)
end

def endpoint_uri(path)
  [Syncano::Connection.api_root,"v1", path].join("/")
end

