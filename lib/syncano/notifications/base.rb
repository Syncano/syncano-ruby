class Syncano
  module Notifications
    class Base
      attr_accessor :id, :source, :target, :data

      def initialize(packet)
        super()
        self.source = packet.source
        self.target = packet.target
        self.data = packet.data
      end

      def self.instantize_notification(packet)
        if packet.message?
          ::Syncano::Notifications::Message.new(packet)
        else
          mapping = {
            new: ::Syncano::Notifications::Create,
            change: ::Syncano::Notifications::Update,
            delete: ::Syncano::Notifications::Destroy,
          }

          mapping[packet.type.to_sym].new(packet)
        end
      end
    end
  end
end