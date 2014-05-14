class Syncano
  module Resources
    class DataObject < ::Syncano::Resources::Base
      def initialize(client, attributes = {}, errors = [])
        super(client, attributes, errors)
        if self.attributes[:children].present?
          self.attributes[:children] = self.attributes[:children].collect do |child|
            if child.is_a?(Hash)
              self.class.new(client, child)
            else
              child
            end
          end
        end

        if self.attributes[:user].is_a?(Hash)
          self.attributes[:user] = ::Syncano::Resources::User.new(client, self.attributes[:user])
        end
      end

      def self.find_by_key(client, key, scope_parameters = {}, conditions = {})
        perform_find(client, :key, key, scope_parameters, conditions)
      end

      def self.count(client, scope_parameters = {}, conditions = {})
        response = perform_count(client, scope_parameters, conditions)
        response.data if response.status
      end

      def self.move(client, scope_parameters = {}, data_ids = [], conditions = {}, new_folder = nil, new_state = nil)
        response = perform_move(client, nil, scope_parameters, data_ids, conditions, new_folder, new_state)

        if response.status
          self.all(client, scope_parameters, data_ids: data_ids)
        end
      end

      def self.batch_move(batch_client, client, scope_parameters = {}, data_ids = [], conditions = {}, new_folder = nil, new_state = nil)
        perform_move(client, batch_client, scope_parameters, data_ids, conditions, new_folder, new_state)
      end

      def move(new_folder = nil, new_state = nil)
        response = perform_move(client, nil, scope_parameters, [id], {}, new_folder, new_state)

        if response.status
          reload!
        end
      end

      def batch_move(batch_client, new_folder = nil, new_state = nil)
        perform_move(client, batch_client, scope_parameters, [id], {}, new_folder, new_state)
      end

      def self.copy(client, scope_parameters = {}, data_ids = [])
        response = perform_copy(client, nil, scope_parameters, data_ids)

        if response.status
          response.data.collect { |attributes| self.new(client, attributes.merge(scope_parameters)) }
        end
      end

      def self.batch_copy(batch_client, client, scope_parameters = {}, data_ids = [])
        perform_copy(client, batch_client, scope_parameters, data_ids)
      end

      def copy
        self.class.copy(client, scope_parameters, id.to_s).try(:first)
      end

      def batch_copy(batch_client)
        self.class.batch_copy(batch_client, client, scope_parameters, id.to_s)
      end

      def add_parent(parent_id, remove_other = false)
        response = perform_add_parent(nil, parent_id, remove_other)
        reload! if response.status

        self
      end

      def batch_add_parent(batch_client, parent_id, remove_other = false)
        perform_add_parent(batch_client, parent_id, remove_other)
      end

      def remove_parent(parent_id = nil)
        response = perform_remove_parent(nil, parent_id)
        reload! if response.status

        self
      end

      def batch_remove_parent(batch_client, parent_id = nil)
        response = perform_remove_parent(batch_client, parent_id)
        reload! if response.status

        self
      end

      def add_child(child_id, remove_other = false)
        response = perform_add_child(nil, child_id, remove_other)
        reload! if response.status

        self
      end

      def batch_add_child(batch_client, child_id, remove_other = false)
        perform_add_child(batch_client, child_id, remove_other)
      end

      def remove_child(child_id = nil)
        response = perform_remove_child(nil, child_id)
        reload! if response.status

        self
      end

      def batch_remove_child(batch_client, child_id = nil)
        perform_remove_child(batch_client, child_id)
      end

      private

      self.syncano_model_name = 'data'
      self.scope_parameters = [:project_id, :collection_id]

      def self.attributes_to_sync(attributes)
        attributes = attributes.dup
        if attributes.keys.map(&:to_sym).include?(:image)
          if attributes[:image].blank?
            attributes[:image] = ''
          elsif attributes[:image].is_a?(String)
            attributes[:image] = Base64.encode64(File.read(attributes[:image]))
          else
            attributes.delete(:image)
          end
        end

        attributes.delete(:user)

        attributes
      end

      def self.perform_count(client, scope_parameters, conditions)
        make_request(client, nil, :count, conditions.merge(scope_parameters))
      end

      def self.perform_move(client, batch_client, scope_parameters, data_ids, conditions, new_folder, new_state)
        move_params = { new_folder: new_folder, new_state: new_state }.delete_if { |k, v| v.nil? }
        make_request(client, batch_client, :save, [conditions, { data_ids: data_ids }, move_params, scope_parameters].inject(&:merge))
      end

      def self.perform_copy(client, batch_client, scope_parameters, data_ids)
        make_request(client, batch_client, :copy, { data_ids: data_ids }.merge(scope_parameters))
      end

      def perform_add_parent(batch_client, parent_id, remove_other = false)
        self.class.make_member_request(client, batch_client, :add_parent, self.class.primary_key, scope_parameters.merge(
          self.class.primary_key => primary_key,
          parent_id: parent_id,
          remove_other: remove_other
        ))
      end

      def perform_remove_parent(batch_client, parent_id)
        self.class.make_member_request(client, batch_client, :remove_parent, self.class.primary_key, scope_parameters.merge(
            self.class.primary_key => primary_key,
            parent_id: parent_id
        ))
      end

      def perform_add_child(batch_client, child_id, remove_other = false)
        self.class.make_member_request(client, batch_client, :add_child, self.class.primary_key, scope_parameters.merge(
            self.class.primary_key => primary_key,
            child_id: child_id,
            remove_other: remove_other
        ))
      end

      def perform_remove_child(batch_client, child_id)
        self.class.make_member_request(client, batch_client, :remove_child, self.class.primary_key, scope_parameters.merge(
            self.class.primary_key => primary_key,
            child_id: child_id
        ))
      end
    end
  end
end