class Syncano
  module Resources
    module Notifications
      class Update < Syncano::Resources::Notifications::Base

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