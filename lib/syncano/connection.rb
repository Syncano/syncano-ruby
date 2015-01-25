module Syncano
  class Connection
    def initialize(options = {})
      self.api_key = options[:api_key]
      self.api_root = ENV['API_ROOT']
    end

    def authenticated?
      !api_key.nil?
    end

    private

    attr_accessor :api_key
  end
end
