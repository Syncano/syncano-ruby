module Syncano
  class API
    cattr_accessor :schema

    def initialize(connection)
      self.connection = connection
      API.schema = ::Syncano::Schema.new(connection)
      API.schema.process!
    end

    private

    attr_accessor :connection
  end
end
