class Syncano
  module Resources
    class Admin < ::Syncano::Resources::Base
      def self.find_by_email(client, email, scope_parameters = {}, conditions = {})
        find_by(client, conditions.merge(scope_parameters.merge(email: email)))
      end
    end
  end
end