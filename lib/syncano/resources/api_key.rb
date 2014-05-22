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
          @attributes[:role] = ::Syncano::Resources::Role.new(@attributes[:role])
        end

        if @saved_attributes[:role].is_a?(Hash)
          @saved_attributes[:role] = ::Syncano::Resources::Role.new(@saved_attributes[:role])
        end
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

      # Executes proper update request
      # @param [Jimson::BatchClient] batch_client
      # @param [Hash] attributes
      # @return [Syncano::Response]
      def perform_update(batch_client, attributes)
        self.class.make_request(client, batch_client, :update_description, self.class.attributes_to_sync(attributes).merge(self.class.primary_key_name.to_sym => primary_key))
      end
    end
  end
end