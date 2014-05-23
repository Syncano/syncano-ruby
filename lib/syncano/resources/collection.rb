class Syncano
  module Resources
    # Collection resource
    class Collection < ::Syncano::Resources::Base
      # Association has_many :folders
      # @return [Syncano::QueryBuilder] query builder for resource Syncano::Resources::Folder
      def folders
        ::Syncano::QueryBuilder.new(client, ::Syncano::Resources::Folder, scope_parameters.merge(collection_id: id))
      end

      # Association has_many :data_objects
      # @return [Syncano::QueryBuilder] query builder for resource Syncano::Resources::DataObject
      def data_objects
        ::Syncano::QueryBuilder.new(client, ::Syncano::Resources::DataObject, scope_parameters.merge(collection_id: id))
      end

      # Association has_many :users
      # @return [Syncano::QueryBuilder] query builder for resource Syncano::Resources::User
      def users
        ::Syncano::QueryBuilder.new(client, ::Syncano::Resources::User, scope_parameters.merge(collection_id: id))
      end

      # Wrapper for api "get_one" method with collection_key as a key
      # @param [Syncano::Clients::Base] client
      # @param [String] key
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Syncano::Resources::Collection]
      def self.find_by_key(client, key, scope_parameters = {}, conditions = {})
        perform_find(client, :key, key, scope_parameters, conditions)
      end

      # Wrapper for api "activate" method
      # @param [TrueClass, FalseClass] force
      # @return [Syncano::Resources::Collection]
      def activate(force = false)
        response = perform_activate(nil, force)
        reload! if response.status

        self
      end

      # Batch version of "activate" method
      # @param [Jimson::BatchClient] batch_client
      # @param [TrueClass, FalseClass] force
      # @return [Syncano::Response]
      def batch_activate(batch_client, force = false)
        perform_activate(batch_client, force)
      end

      # Wrapper for api "deactivate" method
      # @return [Syncano::Resources::Collection]
      def deactivate
        response = perform_deactivate(nil)
        reload! if response.status

        self
      end

      # Batch version of "deactivate" method
      # @param [Jimson::BatchClient] batch_client
      # @return [Syncano::Response]
      def batch_deactivate(batch_client)
        perform_deactivate(batch_client)
      end

      # Wrapper for api "add_tag" method
      # @param [String, Array] tags
      # @param [Numeric] weight
      # @param [TrueClass, FalseClass] remove_other
      # @return [Syncano::Resources::Collection]
      def add_tag(tags, weight = 1, remove_other = false)
        response = perform_add_tag(nil, tags, weight, remove_other)
        reload! if response.status

        self
      end

      # Batch version of "add_tags" method
      # @param [Jimson::BatchClient] batch_client
      # @param [String, Array] tags
      # @param [Numeric] weight
      # @param [TrueClass, FalseClass] remove_other
      # @return [Syncano::Response]
      def batch_add_tags(batch_client, tags, weight = 1, remove_other = false)
        perform_add_tag(batch_client, tags, weight, remove_other)
      end

      # Wrapper for api "delete_tag" method
      # @param [String, Array] tags
      # @return [Syncano::Resources::Collection]
      def delete_tags(tags)
        response = perform_delete_tag(nil, tags)
        reload! if response.status

        self
      end

      # Batch version of "delete_tag" method
      # @param [Jimson::BatchClient] batch_client
      # @param [String, Array] tags
      # @return [Syncano::Response]
      def batch_delete_tag(batch_client, tags)
        perform_delete_tag(batch_client, tags)
      end

      # Wrapper for api "subscription.subscribe_collection" method
      # @return [Syncano::Resource::Collection]
      def subscribe
        perform_subscribe
        reload!
      end

      # Wrapper for api "subscription.unsubscribe_collection" method
      # @return [Syncano::Resource::Collection]
      def unsubscribe
        perform_unsubscribe
        reload!
      end

      private

      self.scope_parameters = [:project_id]

      # Executes proper activate request
      # @param [Jimson::BatchClient] batch_client
      # @param [TrueClass, FalseClass] force
      # @return [Syncano::Response]
      def perform_activate(batch_client, force)
        self.class.make_request(client, batch_client, :activate, scope_parameters.merge(
          self.class.primary_key_name => primary_key,
          force: force
        ))
      end

      # Executes proper deactivate request
      # @param [Jimson::BatchClient] batch_client
      # @return [Syncano::Response]
      def perform_deactivate(batch_client)
        self.class.make_request(client, batch_client, :deactivate, scope_parameters.merge(
          self.class.primary_key_name => primary_key
        ))
      end

      # Executes proper add_tags request
      # @param [Jimson::BatchClient] batch_client
      # @param [String, Array] tags
      # @param [Numeric] weight
      # @param [TrueClass, FalseClass] remove_other
      # @return [Syncano::Response]
      def perform_add_tags(batch_client, tags, weight, remove_other)
        self.class.make_request(client, batch_client, :add_tag, scope_parameters.merge(
          self.class.primary_key_name => primary_key,
          tags: tags,
          weight: weight,
          remove_other: remove_other
        ))
      end

      # Executes proper delete_tags request
      # @param [Jimson::BatchClient] batch_client
      # @param [String, Array] tags
      # @return [Syncano::Response]
      def perform_delete_tags(batch_client, tags)
        self.class.make_request(client, batch_client, :delete_tag, scope_parameters.merge(
          self.class.primary_key_name => primary_key,
          tags: tags
        ))
      end

      # Executes proper subscribe request
      # @return [Syncano::Response]
      def perform_subscribe
        check_if_sync_client!
        client.make_request(:subscription, :subscribe_collection, scope_parameters.merge(collection_id: id))
      end

      # Executes proper unsubscribe request
      # @return [Syncano::Response]
      def perform_unsubscribe
        check_if_sync_client!
        client.make_request(:subscription, :unsubscribe_collection, scope_parameters.merge(collection_id: id))
      end
    end
  end
end