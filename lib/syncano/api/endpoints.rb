module Syncano
  class API
    module Endpoints
      def self.definition(resources_definition)
        Module.new do
          resources_definition.each do |resource_definition|
            resource_class = ::Syncano::Resources.define_resource_class(resource_definition)

            define_method(resource_definition.name.tableize) do
              ::Syncano::QueryBuilder.new(connection, resource_class)
            end if resource_definition.top_level?
          end
        end
      end
    end
  end
end