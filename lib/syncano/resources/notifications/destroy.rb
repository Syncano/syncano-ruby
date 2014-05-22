class Syncano
  module Resources
    module Notifications
      # Notification resource about destroying data object - represents notification with type "delete"
      class Destroy < Syncano::Resources::Notifications::Base

        # Constructor for Syncano::Notifications::Create object
        # @param [Syncano::Clients::Base] client
        # @param [Hash] attributes
        def initialize(client, attributes)
          super(client, attributes)

          if attributes.is_a?(::Syncano::Packets::Base)
            self[:target] = attributes.target
          end
        end
      end
    end
  end
end