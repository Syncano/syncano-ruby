class Syncano
  module Resources
    module Notifications
      class Destroy < Syncano::Resources::Notifications::Base

        def initialize(client, attributes)
          super(client, attributes)

          if attributes.is_a?(::Syncano::Packets::Base)
            self[:target] = packet.target
          end
        end
      end
    end
  end
end