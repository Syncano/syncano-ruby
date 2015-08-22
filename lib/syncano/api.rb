module Syncano
  class API

    def initialize(connection)
      self.connection = connection

      self.class.initialize(connection) unless self.class.initialized?
    end

    class << self
      def initialize(connection)
        endpoints = Schema::EndpointsWhitelist.new(Schema.new(connection))

        resources_definitions = Resources.build_definitions(endpoints)

        include Syncano::API::Endpoints.definition(resources_definitions)

        self.initialized = true
      end

      def initialized?
        initialized
      end
    end

    private

    attr_accessor :connection
    cattr_accessor :initialized
  end
end
