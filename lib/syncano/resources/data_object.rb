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

      def self.find_by_key(client, key, scope_parameters = {})
        find_by(client, scope_parameters.merge(key: key))
      end

      def self.move(client, scope_parameters = {}, data_ids = [], conditions = {}, new_folder = nil, new_state = nil)
        move_params = { new_folder: new_folder, new_state: new_state }.delete_if { |k, v| v.nil? }

        response = make_request(client, __method__, [conditions, { data_ids: data_ids }, move_params, scope_parameters].inject(&:merge))

        if response.status
          self.all(client, scope_parameters, data_ids: data_ids)
        end
      end

      def move(new_folder = nil, new_state = nil)
        self.class.move(client, scope_parameters, id, {}, new_folder, new_state).try(:first)
        reload!
      end

      def self.copy(client, scope_parameters = {}, data_ids = [])
        response = make_request(client, __method__, { data_ids: data_ids }.merge(scope_parameters))

        if response.status
          response.data.collect { |attributes| self.new(client, attributes.merge(scope_parameters)) }
        end
      end

      def copy
        self.class.copy(client, scope_parameters, id.to_s).try(:first)
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
    end
  end
end