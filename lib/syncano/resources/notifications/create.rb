class Syncano
  module Resources
    module Notifications
      class Create < Syncano::Resources::Notifications::Base

        def initialize(client, attributes)
          super(client, attributes)

          if attributes.is_a?(::Syncano::Packets::Base)
            self[:channel] = packet.channel
          end
        end
      end
    end
  end
end