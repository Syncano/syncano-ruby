class Syncano
  module Packets
    # Class representing call response packets used in communication with the Sync Server
    class CallResponse < Syncano::Packets::Base
      attr_reader :message_id, :data, :result

      # Constructor for Syncano::Packets::CallResponse object
      # @param [Hash] attributes
      def initialize(attributes)
        super(attributes)
        self.message_id = attributes[:message_id]
        self.data = attributes[:data]
        self.result = attributes[:result]
      end

      # Prepares hash in response format
      # @return [Hash]
      def to_response
        data.merge(result: result)
      end

      # Returns true if is a call response packet
      # @return [TrueClass, FalseClass]
      def call_response?
        true
      end

      private

      attr_writer :message_id, :data, :result
    end
  end
end