class Syncano
  module Resources
    # Admin resource
    class Admin < ::Syncano::Resources::Base
      # Wrapper for api "get_one" method with admin_email as a key
      # @param [Syncano::Clients::Base] client
      # @param [String] email
      # @param [Hash] scope_parameters
      # @param [Hash] conditions
      # @return [Syncano::Resources::Admin]
      def self.find_by_email(client, email, scope_parameters = {}, conditions = {})
        perform_find(client, :admin_email, email, scope_parameters, conditions)
      end

      # Wrapper for api "new" method
      # Creates object in Syncano
      # @param [Syncano::Clients::Base] client
      # @param [Hash] attributes
      # @return [Syncano::Resources::Base]
      def self.create(client, attributes)
        perform_create(client, nil, attributes)
        all(client, map_to_scope_parameters(attributes)).last
      end
    end
  end
end