class Syncano
  module Packets
    class Base
      attr_accessor :timestamp, :object

      def initialize(attributes)
        super()
        self.timestamp = attributes[:timestamp]
        self.object = attributes[:object]
      end

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

      def notification?
        false
      end

      def ping?
        false
      end

      def call_response?
        false
      end

      def message?
        false
      end
    end
  end
end