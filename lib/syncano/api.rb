module Syncano
  class API

    def initialize(connection)
      self.connection = connection
      Schema.instance
    end

    private

    attr_accessor :connection
  end
end
