class Syncano
  module Resources
    class DataObject < ::Syncano::Resources::Base
      def self.find_by_key(client, key, scope_parameters = {})
        find_by(client, scope_parameters.merge(key: key))
      end

      def move

      end

      def copy

      end

      def add_parent(parent_id, remove_other = false)
        response = self.class.make_member_request(client, __method__, scope_parameters.merge(id: id, parent_id: parent_id, remove_other: remove_other))
        reload! if response.status

        self
      end

      def remove_parent(parent_id = nil)
        response = self.class.make_member_request(client, __method__, scope_parameters.merge(id: id, parent_id: parent_id))
        reload! if response.status

        self
      end

      def add_child(child_id, remove_other = false)
        response = self.class.make_member_request(client, __method__, scope_parameters.merge(id: id, child_id: child_id, remove_other: remove_other))
        reload! if response.status

        self
      end

      def remove_child(child_id = nil)
        response = self.class.make_member_request(client, __method__, scope_parameters.merge(id: id, child_id: child_id))
        reload! if response.status

        self
      end

      def self.count(client, scope_parameters = {}, conditions = {})
        response = make_request(client, __method__, conditions.merge(scope_parameters))
        response.data if response.status
      end

      private

      self.syncano_model_name = 'data'
      self.scope_parameters = [:project_id, :collection_id]
    end
  end
end