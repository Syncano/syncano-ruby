class Syncano
  module Notifications
    class Update < Syncano::Notifications::Base
      attr_accessor :added, :updated, :deleted, :target

      def initialize(packet)
        super(packet)
        self.added = packet.data[:added]
        self.updated = packet.data[:updated]
        self.deleted = packet.data[:deleted]
        self.target = packet.target
      end
    end
  end
end