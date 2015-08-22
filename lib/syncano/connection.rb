require 'json'

module Syncano
  class Connection
    API_VERSION = 'v1'
    AUTH_PATH = 'account/auth/'
    METHODS = Set.new [:get, :post, :put, :delete, :head, :patch, :options]

    attr_accessor :api_key
    attr_accessor :user_key

    class << self
      def api_root
        ENV['API_ROOT']
      end
    end

    def http_fetcher
      HttpFetcher.new api_key, user_key
    end

    def initialize(options = {})
      self.api_key = options[:api_key]
      self.email = options[:email]
      self.password = options[:password]
      self.user_key = options[:user_key]

      # TODO: take it easy with SSL for development only, temporary solution
      self.conn = Faraday.new(self.class.api_root,
                              ssl: {
                                ca_file: File.join(File.dirname(__FILE__),
                                                   '../certs/ca-bundle.crt')
                              }) do |faraday|
        faraday.path_prefix = API_VERSION
        faraday.request :multipart
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
      end
    end

    def authenticated?
      !api_key.nil?
    end

    def authenticate
      api_key = request(:post, AUTH_PATH,
                        email: email,
                        password: password)['account_key']
      self.api_key = api_key
    end

    def request(method, path, params = {})
      raise %{Unsupported method "#{method}"} unless METHODS.include? method

      conn.headers['X-API-KEY'] = api_key if api_key
      conn.headers['X-USER-KEY'] = user_key if user_key
      conn.headers['User-Agent'] = "Syncano Ruby Gem #{Syncano::VERSION}"

      raw_response = conn.send(method, path, params)

      Syncano::Response.handle ResponseWrapper.new(raw_response)
    end

    private

    class ResponseWrapper < BasicObject
      def initialize(response)
        @response = response
      end

      def method_missing(name, *args, &block)
        @response.__send__(name, *args, &block)
      end

      def status
        Status.new @response.status
      end

      private

      class Status
        attr_accessor :code

        def initialize(code)
          self.code = code
        end
      end
    end

    attr_accessor :api_root
    attr_accessor :email
    attr_accessor :password
    attr_accessor :conn
  end
end
