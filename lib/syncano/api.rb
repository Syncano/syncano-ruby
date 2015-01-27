module Syncano
  class API
    def initialize(connection)
      self.connection = connection

      parse_schema
    end

    attr_accessor :models

    private

    attr_accessor :connection

    def parse_schema
      # self.models = Models.new(connection) or sth
    end
  end
end
