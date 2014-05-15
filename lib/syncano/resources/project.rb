class Syncano
  module Resources
    class Project < ::Syncano::Resources::Base
      # Association has_many :collections
      # @return [Syncano::QueryBuilder] query builder for resource Syncano::Resources::Collection
      def collections
        ::Syncano::QueryBuilder.new(client, ::Syncano::Resources::Collection, project_id: id)
      end
    end
  end
end