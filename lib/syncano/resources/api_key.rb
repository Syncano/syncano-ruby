class Syncano
  module Resources
    class ApiKey < ::Syncano::Resources::Base
      def initialize(client, attributes = {}, errors = [])
        super(client, attributes, errors)
        if @attributes[:role].is_a?(Hash)
          @attributes[:role] = ::Syncano::Resources::Role.new(@attributes[:role])
        end

        if @saved_attributes[:role].is_a?(Hash)
          @saved_attributes[:role] = ::Syncano::Resources::Role.new(@saved_attributes[:role])
        end
      end

      private

      def self.attributes_to_sync(attributes)
        attributes = attributes.dup
        [:role, :role_id].each { |attribute| attributes.delete(:attribute) }

        attributes
      end

      def perform_update(batch_client, attributes)
        self.class.make_member_request(client, batch_client, :update_description, self.class.primary_key, self.class.attributes_to_sync(attributes).merge(self.class.primary_key.to_sym => primary_key))
      end
    end
  end
end