class Syncano
  module Packets
    class CallResponse < Syncano::Packets::Base
      attr_accessor :message_id

      def initialize(attributes)
        super(attributes)
        self.message_id = attributes[:message_id]
      end

      def call_response?
        true
      end
    end
  end
end