module Syncano
  class API
    def initialize(connection)
      self.connection = connection
      schema = ::Syncano::Schema.new(connection)
      schema.process!
    end

    private

    attr_accessor :connection
  end
end
