class Syncano
  module Resources
    class User < ::Syncano::Resources::Base
      def self.count(client, scope_parameters = {}, conditions = {})
        response = perform_count(client, scope_parameters, conditions)
        response.data if response.status
      end

      private

      self.scope_parameters = [:project_id, :collection_id]

      def self.perform_count(client, scope_parameters, conditions)
        make_request(client, nil, :count, conditions.merge(scope_parameters))
      end
    end
  end
end