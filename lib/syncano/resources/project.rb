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
    end
  end
end