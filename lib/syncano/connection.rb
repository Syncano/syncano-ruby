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

      # FIXME take it easy with SSL for development only, temporary solution
      self.conn = Faraday.new(self.class.api_root, ssl: { verify: false })
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
      body = JSON.parse(response.body)

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
      response = conn.send(method, path, params)

      case response
      when Status.successful
        JSON.parse(response.body)
      when Status.client_error
        raise ClientError.new(response.body, response)
      end
    end

    private

    class Status
      class << self
        def successful
          ->(response) { (200...300).include? response.status }
        end

        def client_error
          ->(response) { (400...500).include? response.status }
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
