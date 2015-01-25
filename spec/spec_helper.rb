require 'bundler'
Bundler.setup

require 'dotenv'
Dotenv.load

require 'syncano'
require 'webmock/rspec'

WebMock.allow_net_connect!

