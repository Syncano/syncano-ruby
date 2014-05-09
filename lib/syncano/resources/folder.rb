class Syncano
  module Resources
    class Folder < ::Syncano::Resources::Base
      # Wrapper for api "get_one" method
      # @param [Syncano::Client] client
      # @param [String] name
      # @param [Hash] scope_parameters
      # @return [Syncano::Resource::Folder]
      def self.find(client, name, scope_parameters = {})
        find_by_name(client, name, scope_parameters)
      end

      # Wrapper for api "get_one" method
      # @param [Syncano::Client] client
      # @param [String] name
      # @param [Hash] scope_parameters
      # @return [Syncano::Resource::Folder]
      def self.find_by_name(client, name, scope_parameters = {})
        find_by(client, scope_parameters.merge(name: name))
      end

      private

      # Method for generating primary key used in api
      # @return [String]
      def primary_key
        @saved_attributes[:name]
      end

      @@scope_parameters = [:project_id, :collection_id]
    end
  end
end