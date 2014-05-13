class Syncano
  module Resources
    class User < ::Syncano::Resources::Base
      def self.count(client, scope_parameters = {}, conditions = {})
        response = make_request(client, __method__, conditions.merge(scope_parameters))
        response.data if response.status
      end

      private

      self.scope_parameters = [:project_id, :collection_id]
    end
  end
end