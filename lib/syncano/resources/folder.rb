class Syncano
  module Resources
    class Folder < ::Syncano::Resources::Base

      def data_objects
        ::Syncano::QueryBuilder.new(client, ::Syncano::Resources::DataObject, scope_parameters.merge(folder: @saved_attributes[:name]))
      end

      # Wrapper for api "get_one" method
      # @param [Syncano::Client] client
      # @param [String] name
      # @param [Hash] scope_parameters
      # @return [Syncano::Resource::Folder]
      def self.find_by_name(client, name, scope_parameters = {}, conditions = {})
        perform_find(client, :name, name, scope_parameters, conditions)
      end

      private

      self.primary_key = :name
      self.scope_parameters = [:project_id, :collection_id]
    end
  end
end