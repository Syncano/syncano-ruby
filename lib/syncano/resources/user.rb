class Syncano
  module Resources
    # User resource
    class User < ::Syncano::Resources::Base
      # Wrapper for api "count" method
      # @param [Syncano::Clients::Base] client
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Integer]
      def self.count(client, scope_parameters = {}, conditions = {})
        response = perform_count(client, scope_parameters, conditions)
        response.data if response.status
      end

      # Wrapper for api "login" method
      # @param [Syncano::Clients::Base] client
      # @param [String] username
      # @param [String] password
      # @return [Integer]
      def self.login(client, username, password)
        response = perform_login(client, user_name: username, password: password)
        response.data
      end

      private

      self.scope_parameters = [:project_id, :collection_id]

      # Prepares hash with attributes used in synchronization with Syncano
      # @return [Hash]
      def self.attributes_to_sync(attributes)
        attributes = attributes.dup

        if attributes.keys.map(&:to_sym).include?(:avatar)
          if attributes[:avatar].blank?
            attributes[:avatar] = ''
          elsif attributes[:avatar].is_a?(String)
            attributes[:avatar] = Base64.encode64(File.read(attributes[:avatar]))
          else
            attributes.delete(:image)
          end
        end

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

      # Executes proper login request
      # @param [Syncano::Clients::Base] client
      # @param [Hash] parameters
      # @return [Syncano::Response]
      def self.perform_login(client, parameters = {})
        make_request(client, nil, :login, parameters, :auth_key)
      end
    end
  end
end