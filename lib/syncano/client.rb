require "syncano/client/version"

module Syncano
  module Client
    SYNCANO_HOST = "#{SYNCANO_INSTANCE}.syncano.com"

    def self.get_projects
      client = ::Jimson::Client.new("https://#{SYNCANO_HOST}/api/jsonrpc")
      client.send('project.get', api_key: 'f527ab610cc0748b37f6c4b54dcf0dcb21675f0a')
    end
  end
end
