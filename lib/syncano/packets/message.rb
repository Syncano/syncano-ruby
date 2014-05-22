class Syncano
  module Packets
    # Class representing message packets used in communication with the Sync Server
    class Message < Syncano::Packets::Base
      attr_accessor :id, :source, :target, :data

      # Constructor for Syncano::Packets::Message object
      # @param [Hash] attributes
      def initialize(attributes)
        super(attributes)
        self.id = attributes[:id]
        self.source = attributes[:source]
        self.target = attributes[:target]
        self.data = attributes[:data]
      end

      # Returns true if is a notification packet
      # @return [TrueClass, FalseClass]
      def notification?
        true
      end

      # Returns true if is a message packet
      # @return [TrueClass, FalseClass]
      def message?
        true
      end
    end
  end
end