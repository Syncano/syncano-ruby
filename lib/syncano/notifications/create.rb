class Syncano
  module Notifications
    class Create < Syncano::Notifications::Base
      attr_accessor :channel

      def initialize(packet)
        super(packet)
        self.channel = packet.channel
      end
    end
  end
end