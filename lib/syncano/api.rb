module Syncano
  class API

    def initialize(connection)
      self.connection = connection

      self.class.initialize(connection) unless self.class.initialized?
    end

    class << self
      def initialize(connection)
        endpoints = Schema::EndpointsWhitelist.new(Schema.new(connection))

        resource_definitions = Resources.build_definitions(endpoints)
        resource_definitions.each do |resource_definition|
          resource_class = ::Syncano::Resources.define_resource_class(resource_definition)

          # TODO define a module to include instad of defining indivudal methods
          define_client_method resource_definition, resource_class if resource_definition.top_level?
        end

        self.initialized = true
      end

      def initialized?
        initialized
      end

      def define_client_method(resource_definition, resource_class)
        define_method(resource_definition.name.tableize) do
          ::Syncano::QueryBuilder.new(connection, resource_class)
        end
      end
    end

    private

    attr_accessor :connection
    cattr_accessor :initialized
  end
end
