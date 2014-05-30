class Syncano
  module Packets
    # Class representing auth packets used in communication with the Sync Server
    class Auth < Syncano::Packets::Base
      attr_reader :message_id, :status, :error

      # Constructor for Syncano::Packets::Auth object
      # @param [Hash] attributes
      def initialize(attributes)
        super(attributes)
        self.message_id = 'auth'
        self.status = attributes[:result]
        self.error = attributes[:error]
      end

      # Returns true if is an auth packet
      # @return [TrueClass, FalseClass]
      def auth?
        true
      end

      private

      attr_writer :message_id, :status, :error
    end
  end
end