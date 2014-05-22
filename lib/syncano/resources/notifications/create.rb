class Syncano
  module Resources
    module Notifications
      # Notification resource about creating data object - represents notification with type "new"
      class Create < Syncano::Resources::Notifications::Base

        # Constructor for Syncano::Notifications::Create object
        # @param [Syncano::Clients::Base] client
        # @param [Hash] attributes
        def initialize(client, attributes)
          super(client, attributes)

          if attributes.is_a?(::Syncano::Packets::Base)
            self[:channel] = attributes.channel
          end
        end
      end
    end
  end
end