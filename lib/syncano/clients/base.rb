class Syncano
  module Clients
    class Base
      attr_accessor :instance_name, :api_key

      # Constructor for Syncano::Client object
      # @param [String] instance_name
      # @param [String] api_key
      def initialize(instance_name, api_key)
        super()

        self.instance_name = instance_name
        self.api_key = api_key
      end

      # Returns query builder for Syncano::Resources::Admin objects
      # @return [Syncano::QueryBuilder]
      def admins
        ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Admin)
      end

      # Returns query builder for Syncano::Resources::ApiKey objects
      # @return [Syncano::QueryBuilder]
      def api_keys
        ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::ApiKey)
      end

      # Returns query builder for Syncano::Resources::Role objects
      # @return [Syncano::QueryBuilder]
      def roles
        ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Role)
      end

      # Returns query builder for Syncano::Resources::Project objects
      # @return [Syncano::QueryBuilder]
      def projects
        ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Project)
      end

      # Returns query builder for Syncano::Resources::Project objects
      # @param [Integer, String] project_id
      # @return [Syncano::QueryBuilder]
      def collections(project_id)
        ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Collection, project_id: project_id)
      end

      # Returns query builder for Syncano::Resources::Folder objects
      # @param [Integer, String] project_id
      # @param [Integer, String] collection_id
      # @return [Syncano::QueryBuilder]
      def folders(project_id, collection_id)
        ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::Collection, project_id: project_id, collection_id: collection_id)
      end

      # Returns query builder for Syncano::Resources::DataObject objects
      # @param [Integer, String] project_id
      # @param [Integer, String] collection_id
      # @return [Syncano::QueryBuilder]
      def data_objects(project_id, collection_id)
        ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::DataObject, project_id: project_id, collection_id: collection_id)
      end

      # Returns query builder for Syncano::Resources::User objects
      # @param [Integer, String] project_id
      # @param [Integer, String] collection_id
      # @return [Syncano::QueryBuilder]
      def users(project_id, collection_id)
        ::Syncano::QueryBuilder.new(self, ::Syncano::Resources::User, project_id: project_id, collection_id: collection_id)
      end

      # Performs request to Syncano api
      # @param [String] resource_name
      # @param [String] method_name
      # @param [Hash] params additional params sent in the request
      # @return [Syncano::Response]
      def make_request(resource_name, method_name, params = {})
      end

      # Performs batch request to Syncano api
      # @param [Jimson::BatchClient] batch_client
      # @param [String] resource_name
      # @param [String] method_name
      # @param [Hash] params additional params sent in the request
      def make_batch_request(batch_client, resource_name, method_name, params = {})
      end

      private

      # Parses Syncano api response and returns Syncano::Response object
      # @param [String] resource_name
      # @param [Hash] raw_response
      # @return [Syncano::Response]
      def self.parse_response(response_key, raw_response)
        status = raw_response.nil? || raw_response['result'] != 'NOK'
        if raw_response.nil?
          data = nil
        elsif raw_response[response_key].present?
          data = raw_response[response_key]
        else
          data = raw_response['count']
        end
        errors = status ? [] : raw_response['error']

        ::Syncano::Response.new(status, data, errors)
      end
    end
  end
end