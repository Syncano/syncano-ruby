module Syncano
  class Connection
    API_VERSION = "v1"
    AUTH_PATH = "/account/auth/"

    def initialize(options = {})
      self.api_root = ENV['API_ROOT']

      self.api_key = options[:api_key]
      self.email = options[:email]
      self.password = options[:password]
    end

    def authenticated?
      !api_key.nil?
    end

    def authenticate
      conn = Faraday.new(url: api_root)
      conn.port = 443

      response = conn.post do |request|
        request.url "#{API_VERSION}#{AUTH_PATH}"
        request.params[:email] = email
        request.params[:password] = password
      end
    end

    private

    attr_accessor :api_key
    attr_accessor :api_root
    attr_accessor :email
    attr_accessor :password
  end
end
