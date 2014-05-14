class Syncano
  module Resources
    class Admin < ::Syncano::Resources::Base
      def self.find_by_email(client, email, scope_parameters = {}, conditions = {})
        perform_find(client, :email, email, scope_parameters, conditions)
      end
    end
  end
end