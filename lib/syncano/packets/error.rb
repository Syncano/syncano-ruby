class Syncano
  module Packets
    # Class representing error packets used in communication with the Sync Server
    class Error < Syncano::Packets::Base
      attr_reader :error

      # Constructor for Syncano::Packets::Error object
      # @param [Hash] attributes
      def initialize(attributes)
        super(attributes)
        self.error = attributes[:error]
      end

      private

      attr_writer :error
    end
  end
end