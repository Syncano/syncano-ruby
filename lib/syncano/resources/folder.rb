class Syncano
  module Resources
    # Folder resource
    class Folder < ::Syncano::Resources::Base
      # Association has_many :data_objects
      # @return [Syncano::QueryBuilder] query builder for resource Syncano::Resources::DataObject
      def data_objects
        ::Syncano::QueryBuilder.new(client, ::Syncano::Resources::DataObject, scope_parameters.merge(folders: @saved_attributes[:name]))
      end

      # Wrapper for api "get_one" method with folder_name as a key
      # @param [Syncano::Clients::Base] client
      # @param [String] name
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Syncano::Resources::Folder]
      def self.find_by_name(client, name, scope_parameters = {}, conditions = {})
        find(client, name, scope_parameters, conditions)
      end

      # Wrapper for api "authorize" method
      # @param [Integer] api_client_id
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def authorize(api_client_id, permission)
        perform_authorize(nil, api_client_id: api_client_id, permission: permission)
        self
      end

      # Wrapper for api "authorize" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] api_client_id
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def batch_authorize(batch_client, api_client_id, permission)
        perform_authorize(batch_client, api_client_id: api_client_id, permission: permission)
        self
      end

      # Wrapper for api "deauthorize" method
      # @param [Integer] api_client_id
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def deauthorize(api_client_id, permission)
        perform_deauthorize(nil, api_client_id: api_client_id, permission: permission)
        self
      end

      # Wrapper for api "deauthorize" method
      # @param [Jimson::BatchClient] batch_client
      # @param [Integer] api_client_id
      # @param [String] permission
      # @return [Syncano::Resources::Base]
      def batch_deauthorize(batch_client, api_client_id, permission)
        perform_deauthorize(batch_client, api_client_id: api_client_id, permission: permission)
        self
      end

      private

      self.primary_key = :name
      self.scope_parameters = [:project_id, :collection_id]

      # Executes proper destroy request
      # @param [Jimson::BatchClient] batch_client
      # @return [Syncano::Response]
      def perform_destroy(batch_client)
        self.class.make_request(client, batch_client, :destroy, scope_parameters.merge(name: primary_key))
      end

      # Executes proper authorize request
      # @param [Jimson::BatchClient] batch_client
      # @param [Hash] parameters
      # @return [Syncano::Response]
      def perform_authorize(batch_client, parameters)
        self.class.make_request(client, batch_client, :authorize, scope_parameters.merge(parameters.merge(self.class.primary_key_name.to_sym => primary_key)))
      end

      # Executes proper deauthorize request
      # @param [Jimson::BatchClient] batch_client
      # @param [Hash] parameters
      # @return [Syncano::Response]
      def perform_deauthorize(batch_client, parameters)
        self.class.make_request(client, batch_client, :deauthorize, scope_parameters.merge(parameters.merge(self.class.primary_key_name.to_sym => primary_key)))
      end
    end
  end
end