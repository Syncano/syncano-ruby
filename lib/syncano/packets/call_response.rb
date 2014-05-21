class Syncano
  module Packets
    class CallResponse < Syncano::Packets::Base
      attr_accessor :message_id, :data, :result

      def initialize(attributes)
        super(attributes)
        self.message_id = attributes[:message_id]
        self.data = attributes[:data]
        self.result = attributes[:result]
      end

      def to_response
        data.merge(result: result)
      end

      def call_response?
        true
      end
    end
  end
end