class Syncano
  module Resources
    module Notifications
      # Notification resource about updating data object - represents notification with type "change"
      class Update < Syncano::Resources::Notifications::Base
        # Constructor for Syncano::Notifications::Update object
        # @param [Syncano::Clients::Base] client
        # @param [Hash] attributes
        def initialize(client, attributes)
          super(client, attributes)

          if attributes.is_a?(::Syncano::Packets::Base)
            self.attributes = {
              added: attributes.data[:added],
              updated: attributes.data[:updated],
              deleted: attributes.data[:deleted],
              target: attributes.target
            }
          end
        end
      end
    end
  end
end