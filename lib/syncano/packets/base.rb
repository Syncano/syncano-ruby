class Syncano
  # Module used as a scope for classes representing packets
  module Packets
    # Base class for representing packets used in communication with the Sync Server
    class Base
      attr_accessor :timestamp, :object

      # Constructor for Syncano::Packets::Base object
      # @param [Hash] attributes
      def initialize(attributes)
        super()
        self.timestamp = attributes[:timestamp]
        self.object = attributes[:object]
      end

      # Proxy method for creating instance of proper subclass
      # @param [Hash] data
      # @return [Syncano::Packets::Base]
      def self.instantize_packet(data)
        mapping = {
          auth: ::Syncano::Packets::Auth,
          call: ::Syncano::Packets::Call,
          callresponse: ::Syncano::Packets::CallResponse,
          error: ::Syncano::Packets::Error,
          message: ::Syncano::Packets::Message,
          new: ::Syncano::Packets::Notification,
          change: ::Syncano::Packets::Notification,
          delete: ::Syncano::Packets::Notification,
          ping: ::Syncano::Packets::Ping
        }

        mapping[data[:type].to_sym].new(data)
      end

      # Returns true if is a notification packet
      # @return [TrueClass, FalseClass]
      def notification?
        false
      end

      # Returns true if is a ping packet
      # @return [TrueClass, FalseClass]
      def ping?
        false
      end

      # Returns true if is a call response packet
      # @return [TrueClass, FalseClass]
      def call_response?
        false
      end

      # Returns true if is a message packet
      # @return [TrueClass, FalseClass]
      def message?
        false
      end
    end
  end
end