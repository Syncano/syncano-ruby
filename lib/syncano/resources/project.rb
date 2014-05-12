class Syncano
  module Resources
    class Project < ::Syncano::Resources::Base
      def collections
        ::Syncano::QueryBuilder.new(client, ::Syncano::Resources::Collection, project_id: id)
      end
    end
  end
end