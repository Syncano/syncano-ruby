class Syncano
  module Packets
    # Class representing notification packets used in communication with the Sync Server
    class Notification < Syncano::Packets::Base
      attr_accessor :type, :id, :channel, :source, :target, :data

      # Constructor for Syncano::Packets::Notification object
      # @param [Hash] attributes
      def initialize(attributes)
        super(attributes)
        self.id = attributes[:id]
        self.type = attributes[:type]
        self.channel = attributes[:channel]
        self.source = attributes[:source]
        self.target = attributes[:target]

        if type == 'change'
          self.data = {
            added: attributes[:add],
            updated: attributes[:replace],
            deleted: attributes[:delete]
          }
        else
          self.data = attributes[:data]
        end
      end

      # Returns true if is a notification packet
      # @return [TrueClass, FalseClass]
      def notification?
        true
      end
    end
  end
end