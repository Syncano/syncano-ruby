require 'bundler'
Bundler.setup

require 'dotenv'
Dotenv.load

require 'syncano'
require 'webmock/rspec'

WebMock.disable_net_connect!
