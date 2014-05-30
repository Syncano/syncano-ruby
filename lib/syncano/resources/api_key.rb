class Syncano
  module Resources
    # Api key resource
    class ApiKey < ::Syncano::Resources::Base
      # Overwritten constructor with initializing associated role object
      # @param [Syncano::Clients::Base] client
      # @param [Hash] attributes
      def initialize(client, attributes = {})
        super(client, attributes)
        if @attributes[:role].is_a?(Hash)
          @attributes[:role] = ::Syncano::Resources::Role.new(client, @attributes[:role])
        end

        if @saved_attributes[:role].is_a?(Hash)
          @saved_attributes[:role] = ::Syncano::Resources::Role.new(client, @saved_attributes[:role])
        end
      end

      # Wrapper for api "authorize" method
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def authorize(permission)
        perform_authorize(nil, permission: permission)
        self
      end

      # Wrapper for api "authorize" method
      # @param [Jimson::BatchClient] batch_client
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def batch_authorize(batch_client, permission)
        perform_authorize(batch_client, permission: permission)
        self
      end

      # Wrapper for api "deauthorize" method
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def deauthorize(permission)
        perform_deauthorize(nil, permission: permission)
        self
      end

      # Wrapper for api "deauthorize" method
      # @param [Jimson::BatchClient] batch_client
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def batch_deauthorize(batch_client, permission)
        perform_deauthorize(batch_client, permission: permission)
        self
      end

      private

      # Prepares attributes to synchronizing with Syncano
      # @param [Hash] attributes
      # @return [Hash] prepared attributes
      def self.attributes_to_sync(attributes)
        attributes = attributes.dup
        attributes.delete(:role)

        attributes
      end

      # Name of attribute used as primary key
      # @return [Symbol]
      def self.primary_key_name
        :api_client_id
      end

      # Executes proper find request
      # @param [Syncano::Clients::Base] client
      # @param [Symbol, String] key_name
      # @param [Integer, String] key
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Syncano::Response]
      def self.perform_find(client, key_name, key, scope_parameters, conditions)
        key_parameters = key.present? ? { key_name.to_sym => key } : {}
        make_request(client, nil, :find, conditions.merge(scope_parameters.merge(key_parameters)))
      end

      # Executes proper update request
      # @param [Jimson::BatchClient] batch_client
      # @param [Hash] attributes
      # @return [Syncano::Response]
      def perform_update(batch_client, attributes)
        self.class.make_request(client, batch_client, :update_description, self.class.attributes_to_sync(attributes).merge(self.class.primary_key_name.to_sym => primary_key))
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