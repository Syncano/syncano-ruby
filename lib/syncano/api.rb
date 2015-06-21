module Syncano
  class API

    def initialize(connection)
      self.connection = connection

      self.class.initialize(connection) unless self.class.initialized?
    end

    class << self
      def initialize(connection)
        resource_definitions = Resources.build_definitions(Schema.new(connection).definition)
        resource_definitions.each do |resource_definition|
          resource_class = ::Syncano::Resources.define_resource_class(resource_definition)

          # TODO define a module to include instad of defining indivudal methods
          define_client_method resource_definition, resource_class if resource_definition.top_level?
        end

        self.initialized = true

        # schema.each do |name, raw_resource_definition|

          #     resource_definition = ::Syncano::Schema::ResourceDefinition.new(name, raw_resource_definition)
          #     resource_class = ::Syncano::Resources.define_resource_class(resource_definition)
          #
          #     if resource_definition[:collection].present? && resource_definition[:collection][:path].scan(/\{([^}]+)\}/).empty?
          #       self.class.generate_client_method(name, resource_class)
          #     end
          #   end
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
