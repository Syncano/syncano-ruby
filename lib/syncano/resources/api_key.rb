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

      def update(attributes)
        response = self.class.make_member_request(client, 'update_description', self.class.attributes_to_sync(attributes).merge(id: id))

        if response.status
          response.data.delete('id')
          self.attributes = scope_parameters.merge(response.data)
          mark_as_saved!
        else
          self.errors << 'Something went wrong'
        end

        self
      end

      private

      def self.attributes_to_sync(attributes)
        attributes = attributes.dup
        [:role, :role_id].each { |attribute| attributes.delete(:attribute) }

        attributes
      end
    end
  end
end