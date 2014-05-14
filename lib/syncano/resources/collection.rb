class Syncano
  module Resources
    class Collection < ::Syncano::Resources::Base
      def folders
        ::Syncano::QueryBuilder.new(client, ::Syncano::Resources::Folder, scope_parameters.merge(collection_id: id))
      end

      def data_objects
        ::Syncano::QueryBuilder.new(client, ::Syncano::Resources::DataObject, scope_parameters.merge(collection_id: id))
      end

      def users
        ::Syncano::QueryBuilder.new(client, ::Syncano::Resources::User, scope_parameters.merge(collection_id: id))
      end

      def self.find_by_key(client, key, scope_parameters = {}, conditions = {})
        perform_find(client, :key, key, scope_parameters, conditions)
      end

      # Wrapper for api "activate" method
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def activate(force = false)
        response = perform_activate(nil, force)
        reload! if response.status

        self
      end

      def batch_activate(batch_client, force = false)
        perform_activate(batch_client, force)
      end

      # Wrapper for api "deactivate" method
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def deactivate
        response = perform_deactivate(nil)
        reload! if response.status

        self
      end

      def batch_deactivate(batch_client)
        perform_deactivate(batch_client)
      end

      # Wrapper for api "add_tag" method
      # @param [Integer, Hash] key
      # @param [String, Array] tags
      # @param [Float] weight
      # @param [Boolean] remove_other
      # @return [Syncano::Response]
      def add_tag(tags, weight = 1, remove_other = false)
        response = perform_add_tag(nil, tags, weight, remove_other)
        reload! if response.status

        self
      end

      def batch_add_tag(batch_client, tags, weight = 1, remove_other = false)
        perform_add_tag(batch_client, tags, weight, remove_other)
      end

      # Wrapper for api "delete_tag" method
      # @param [Integer, Hash] key
      # @param [String, Array] tags
      # @return [Syncano::Response]
      def delete_tag(tags)
        response = self.class.make_member_request(client, __method__, scope_parameters.merge(id: id, tags: tags))
        reload! if response.status

        self
      end

      def batch_delete_tag(batch_client, tags)
        self.class.make_member_request(client, __method__, scope_parameters.merge(id: id, tags: tags))
      end

      private

      self.scope_parameters = [:project_id]

      def perform_activate(batch_client, force)
        self.class.make_member_request(client, batch_client, :activate, self.class.primary_key, scope_parameters.merge(
          self.class.primary_key.to_sym => primary_key,
          force: force
        ))
      end

      def perform_deactivate(batch_client)
        self.class.make_member_request(client, batch_client, :deactivate, self.class.primary_key, scope_parameters.merge(
          self.class.primary_key.to_sym => primary_key
        ))
      end

      def perform_add_tag(batch_client, tags, weight, remove_other)
        self.class.make_member_request(client, batch_client, :add_tag, self.class.primary_key, scope_parameters.merge(
          self.class.primary_key.to_sym => primary_key,
          tags: tags,
          weight: weight,
          remove_other: remove_other
        ))
      end

      def perform_delete_tag(batch_client, tags)
        self.class.make_member_request(client, batch_client, :delete_tag, self.class.primary_key, scope_parameters.merge(
          self.class.primary_key.to_sym => primary_key,
          tags: tags
        ))
      end
    end
  end
end