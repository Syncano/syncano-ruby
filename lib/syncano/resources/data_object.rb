class Syncano
  module Resources
    # Data object resource - corresponds to Syncano data resource
    class DataObject < ::Syncano::Resources::Base
      # Overwritten constructor with recursive initializing associated children objects
      # @param [Syncano::Clients::Base] client
      # @param [Hash] attributes
      def initialize(client, attributes = {})
        super(client, attributes)
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

      # Wrapper for api "get_one" method with data_key as a key
      # @param [Syncano::Clients::Base] client
      # @param [String] key
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Syncano::Resources::DataObject]
      def self.find_by_key(client, key, scope_parameters = {}, conditions = {})
        perform_find(client, :key, key, scope_parameters, conditions)
      end

      # Wrapper for api "count" method
      # @param [Syncano::Clients::Base] client
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Integer]
      def self.count(client, scope_parameters = {}, conditions = {})
        response = perform_count(client, scope_parameters, conditions)
        response.data
      end

      # Wrapper for api "move" method
      # @param [Syncano::Clients::Base] client
      # @param [Hash] scope_parameters
      # @param [Array] data_ids
      # @param [Hash] conditions
      # @param [String] new_folder
      # @param [String] new_state
      # @return [Array] collection of Syncano::Resource::DataObject objects
      def self.move(client, scope_parameters = {}, data_ids = [], conditions = {}, new_folder = nil, new_state = nil)
        response = perform_move(client, nil, scope_parameters, data_ids, conditions, new_folder, new_state)
        all(client, scope_parameters, data_ids: data_ids)
      end

      # Batch version of "move" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Syncano::Clients::Base] client
      # @param [Hash] scope_parameters
      # @param [Array] data_ids
      # @param [Hash] conditions
      # @param [String] new_folder
      # @param [String] new_state
      # @return [Syncano::Response]
      def self.batch_move(batch_client, client, scope_parameters = {}, data_ids = [], conditions = {}, new_folder = nil, new_state = nil)
        perform_move(client, batch_client, scope_parameters, data_ids, conditions, new_folder, new_state)
      end

      # Wrapper for api "move" method
      # @param [String] new_folder
      # @param [String] new_state
      # @return [Syncano::Resource::DataObject]
      def move(new_folder = nil, new_state = nil)
        perform_move(client, nil, scope_parameters, [id], {}, new_folder, new_state)
        reload!
      end

      # Batch version of "move" method
      # @param [Jimson::BatchClient] batch_client
      # @param [String] new_folder
      # @param [String] new_state
      # @return [Syncano::Response]
      def batch_move(batch_client, new_folder = nil, new_state = nil)
        perform_move(client, batch_client, scope_parameters, [id], {}, new_folder, new_state)
      end

      # Wrapper for api "copy" method
      # @param [Syncano::Clients::Base] client
      # @param [Hash] scope_parameters
      # @param [Array] data_ids
      # @return [Array] collection of Syncano::Resource::DataObject objects
      def self.copy(client, scope_parameters = {}, data_ids = [])
        response = perform_copy(client, nil, scope_parameters, data_ids)
        response.data.collect { |attributes| self.new(client, attributes.merge(scope_parameters)) }
      end

      # Batch version of "move" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Syncano::Clients::Base] client
      # @param [Hash] scope_parameters
      # @param [Array] data_ids
      # @return [Syncano::Response]
      def self.batch_copy(batch_client, client, scope_parameters = {}, data_ids = [])
        perform_copy(client, batch_client, scope_parameters, data_ids)
      end

      # Wrapper for api "copy" method
      # @return [Syncano::Resource::DataObject]
      def copy
        self.class.copy(client, scope_parameters, id.to_s).try(:first)
      end

      # Batch version of "copy" method
      # @param [Jimson::BatchClient] batch_client
      # @return [Syncano::Response]
      def batch_copy(batch_client)
        self.class.batch_copy(batch_client, client, scope_parameters, id.to_s)
      end

      # Wrapper for api "add_parent" method
      # @param [Integer] parent_id
      # @param [TrueClass, FalseClass] remove_other
      # @return [Syncano::Resources::DataObject]
      def add_parent(parent_id, remove_other = false)
        response = perform_add_parent(nil, parent_id, remove_other)
        reload!
      end

      # Batch version of "add_parent" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] parent_id
      # @param [TrueClass, FalseClass] remove_other
      # @return [Syncano::Response]
      def batch_add_parent(batch_client, parent_id, remove_other = false)
        perform_add_parent(batch_client, parent_id, remove_other)
      end

      # Wrapper for api "remove_parent" method
      # @param [Integer] parent_id
      # @return [Syncano::Resources::DataObject]
      def remove_parent(parent_id = nil)
        response = perform_remove_parent(nil, parent_id)
        reload!
      end

      # Batch version of "remove_parent" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] parent_id
      # @return [Syncano::Response]
      def batch_remove_parent(batch_client, parent_id = nil)
        perform_remove_parent(batch_client, parent_id)
      end

      # Wrapper for api "add_child" method
      # @param [Integer] child_id
      # @param [TrueClass, FalseClass] remove_other
      # @return [Syncano::Resources::DataObject]
      def add_child(child_id, remove_other = false)
        perform_add_child(nil, child_id, remove_other)
        reload!
      end

      # Batch version of "add_child" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] child_id
      # @param [TrueClass, FalseClass] remove_other
      # @return [Syncano::Response]
      def batch_add_child(batch_client, child_id, remove_other = false)
        perform_add_child(batch_client, child_id, remove_other)
      end

      # Wrapper for api "remove_child" method
      # @param [Integer] child_id
      # @return [Syncano::Resources::DataObject]
      def remove_child(child_id = nil)
        perform_remove_child(nil, child_id)
        reload!
      end

      # Batch version of "remove_child" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] child_id
      # @return [Syncano::Response]
      def batch_remove_child(batch_client, child_id = nil)
        perform_remove_child(batch_client, child_id)
      end

      private

      self.syncano_model_name = 'data'
      self.scope_parameters = [:project_id, :collection_id]

      # Prepares hash with attributes used in synchronization with Syncano
      # @return [Hash]
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

      # Executes proper count request
      # @param [Syncano::Clients::Base] client
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Syncano::Response]
      def self.perform_count(client, scope_parameters, conditions)
        make_request(client, nil, :count, conditions.merge(scope_parameters))
      end

      # Executes proper move request
      # @param [Syncano::Clients::Base] client
      # @param [Jimson::BatchClient] batch_client
      # @param [Hash] scope_parameters
      # @param [Array] data_ids
      # @param [Hash] conditions
      # @param [String] new_folder
      # @param [String] new_state
      # @return [Syncano::Response]
      def self.perform_move(client, batch_client, scope_parameters, data_ids, conditions, new_folder, new_state)
        move_params = { new_folder: new_folder, new_state: new_state }.delete_if { |k, v| v.nil? }
        make_request(client, batch_client, :save, [conditions, { data_ids: data_ids }, move_params, scope_parameters].inject(&:merge))
      end

      # Executes proper copy request
      # @param [Syncano::Clients::Base] client
      # @param [Jimson::BatchClient] batch_client
      # @param [Hash] scope_parameters
      # @param [Array] data_ids
      # @return [Syncano::Response]
      def self.perform_copy(client, batch_client, scope_parameters, data_ids)
        make_request(client, batch_client, :copy, { data_ids: data_ids }.merge(scope_parameters))
      end

      # Executes proper add_parent request
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] parent_id
      # @param [TrueClass, FalseClass] remove_other
      # @return [Syncano::Response]
      def perform_add_parent(batch_client, parent_id, remove_other = false)
        self.class.make_request(client, batch_client, :add_parent, scope_parameters.merge(
          self.class.primary_key_name => primary_key,
          parent_id: parent_id,
          remove_other: remove_other
        ))
      end

      # Executes proper remove_parent request
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] parent_id
      # @return [Syncano::Response]
      def perform_remove_parent(batch_client, parent_id)
        self.class.make_request(client, batch_client, :remove_parent, scope_parameters.merge(
            self.class.primary_key_name => primary_key,
            parent_id: parent_id
        ))
      end

      # Executes proper add_child request
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] child_id
      # @param [TrueClass, FalseClass] remove_other
      # @return [Syncano::Response]
      def perform_add_child(batch_client, child_id, remove_other = false)
        self.class.make_request(client, batch_client, :add_child, scope_parameters.merge(
            self.class.primary_key_name => primary_key,
            child_id: child_id,
            remove_other: remove_other
        ))
      end

      # Executes proper remove_child request
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] child_id
      # @return [Syncano::Response]
      def perform_remove_child(batch_client, child_id)
        self.class.make_request(client, batch_client, :remove_child, scope_parameters.merge(
            self.class.primary_key_name => primary_key,
            child_id: child_id
        ))
      end
    end
  end
end