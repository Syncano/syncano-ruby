class Syncano
  module Notifications
    class Destroy < Syncano::Notifications::Base
      attr_accessor :target

      def initialize(packet)
        super(packet)
        self.target = packet.target
      end
    end
  end
end