module Syncano
  class Poller
    include Celluloid::IO

    attr_accessor :connection, :method_name, :path, :responses


    def initialize(connection, method_name, path)
      self.connection = connection
      self.method_name = method_name
      self.path = path
      self.responses = []
    end

    def poll
      loop do
        responses << http_fetcher.get(path)
      end
    end

    def last_response
      responses.last
    end

    private

    def http_fetcher
      HttpFetcher.new connection.api_key, connection.user_key
    end

    class HttpFetcher
      attr_accessor :api_key, :user_key

      def initialize(api_key, user_key)
        self.api_key = api_key
        self.user_key = user_key
      end

      def get(path, params = {})
        url = Syncano::Connection.api_root + path

        response = HTTP.
          with_headers('X-API-KEY' => api_key,
                       'X-USER-KEY' => user_key,
                       'User-Agent' => "Syncano Ruby Gem #{Syncano::VERSION}").
          get(url,
              params: params,
              ssl_socket_class: Celluloid::IO::SSLSocket,
              socket_class: Celluloid::IO::TCPSocket)

        response
      end
    end
  end
end