class Syncano
  module Resources
    # Project resource
    class Project < ::Syncano::Resources::Base
      # Association has_many :collections
      # @return [Syncano::QueryBuilder] query builder for resource Syncano::Resources::Collection
      def collections
        ::Syncano::QueryBuilder.new(client, ::Syncano::Resources::Collection, project_id: id)
      end

      # Wrapper for api "subscription.subscribe_project" method
      # @return [Syncano::Resource::Project]
      def subscribe
        perform_subscribe
        reload!
      end

      # Wrapper for api "subscription.unsubscribe_project" method
      # @return [Syncano::Resource::Project]
      def unsubscribe
        perform_unsubscribe
        reload!
      end

      # Wrapper for api "authorize" method
      # @param [Integer] api_client_id
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def authorize(api_client_id, permission)
        perform_authorize(nil, api_client_id: api_client_id, permission: permission)
        self
      end

      # Wrapper for api "authorize" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] api_client_id
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def batch_authorize(batch_client, api_client_id, permission)
        perform_authorize(batch_client, api_client_id: api_client_id, permission: permission)
        self
      end

      # Wrapper for api "deauthorize" method
      # @param [Integer] api_client_id
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def deauthorize(api_client_id, permission)
        perform_deauthorize(nil, api_client_id: api_client_id, permission: permission)
        self
      end

      # Wrapper for api "deauthorize" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] api_client_id
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def batch_deauthorize(batch_client, api_client_id, permission)
        perform_deauthorize(batch_client, api_client_id: api_client_id, permission: permission)
        self
      end

      private

      # Executes proper subscribe request
      # @return [Syncano::Response]
      def perform_subscribe
        check_if_sync_client!
        client.make_request(:subscription, :subscribe_project, { project_id: id })
      end

      # Executes proper unsubscribe request
      # @return [Syncano::Response]
      def perform_unsubscribe
        check_if_sync_client!
        client.make_request(:subscription, :unsubscribe_project, { project_id: id })
      end

      # Executes proper authorize request
      # @param [Jimson::BatchClient] batch_client
      # @param [Hash] parameters
      # @return [Syncano::Response]
      def perform_authorize(batch_client, parameters)
        self.class.make_request(client, batch_client, :authorize, parameters.merge(self.class.primary_key_name.to_sym => primary_key))
      end

      # Executes proper deauthorize request
      # @param [Jimson::BatchClient] batch_client
      # @param [Hash] parameters
      # @return [Syncano::Response]
      def perform_deauthorize(batch_client, parameters)
        self.class.make_request(client, batch_client, :deauthorize, parameters.merge(self.class.primary_key_name.to_sym => primary_key))
      end
    end
  end
end