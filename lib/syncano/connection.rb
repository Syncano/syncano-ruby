require 'json'

module Syncano
  class Connection
    API_VERSION = 'v1'
    AUTH_PATH = 'account/auth/'
    METHODS = Set.new [:get, :post, :put, :delete, :head, :patch, :options]

    def self.api_root
      ENV['API_ROOT']
    end

    def initialize(options = {})
      self.api_key = options[:api_key]
      self.email = options[:email]
      self.password = options[:password]

      # TODO: take it easy with SSL for development only, temporary solution
      self.conn = Faraday.new(self.class.api_root,
        ssl: { ca_file: File.join(File.dirname(__FILE__), '../certs/ca-bundle.crt') })
      conn.path_prefix = API_VERSION
      conn.request :url_encoded
    end

    def authenticated?
      !api_key.nil?
    end

    def authenticate(email, password)
      self.email = email
      self.password = password
      authenticate!
    end

    def authenticate!
      response = conn.post(AUTH_PATH, email: email, password: password)
      body = parse_response(response)

      case response
        when Status.successful
          self.api_key = body['account_key']
        when Status.client_error
          raise ClientError.new(body, response)
      end
    end

    def request(method, path, params = {})
      raise %{Unsupported method "#{method}"} unless METHODS.include? method
      conn.headers['X-API-KEY'] = api_key
      conn.headers['User-Agent'] = "Syncano Ruby Gem #{Syncano::VERSION}"
      response = conn.send(method, path, params)

      case response
        when Status.no_content
        when Status.successful
          parse_response response
        when Status.client_error # TODO figure out if we want to raise an exception on not found or not
          raise ClientError.new(response.body, response)
        when Status.server_error
          raise ServerError.new(response.body, response)
        else
          raise UnsupportedStatusError.new(response)
      end
    end

    private

    def parse_response(response)
      JSON.parse(response.body)
    end

    class Status
      class << self
        def successful
          ->(response) { (200...300).include? response.status }
        end

        def client_error
          ->(response) { (400...500).include? response.status }
        end

        def no_content
          ->(response) { response.status == 204 }
        end

        def server_error
          ->(response) { response.status >= 500 }
        end
      end
    end

    attr_accessor :api_key
    attr_accessor :api_root
    attr_accessor :email
    attr_accessor :password
    attr_accessor :conn
  end
end
