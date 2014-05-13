class Syncano
  module Resources
    class ApiKey < ::Syncano::Resources::Base
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
    end
  end
end