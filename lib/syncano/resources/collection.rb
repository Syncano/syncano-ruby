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
        find_by(client, conditions.merge(scope_parameters.merge(key: key)))
      end

      # Wrapper for api "activate" method
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def activate(force = false)
        response = self.class.make_member_request(client, __method__, scope_parameters.merge(id: id, force: force))
        reload! if response.status

        self
      end

      # Wrapper for api "deactivate" method
      # @param [Integer, Hash] key
      # @return [Syncano::Response]
      def deactivate
        response = self.class.make_member_request(client, __method__, scope_parameters.merge(id: id))
        reload! if response.status

        self
      end

      # Wrapper for api "add_tag" method
      # @param [Integer, Hash] key
      # @param [String, Array] tags
      # @param [Float] weight
      # @param [Boolean] remove_other
      # @return [Syncano::Response]
      def add_tag(tags, weight = 1, remove_other = false)
        response = self.class.make_member_request(client, __method__, scope_parameters.merge(id: id, tags: tags, weight: weight, remove_other: remove_other))
        reload! if response.status

        self
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

      private

      self.scope_parameters = [:project_id]
    end
  end
end