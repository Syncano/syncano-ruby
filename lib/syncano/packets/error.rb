class Syncano
  module Packets
    # Class representing error packets used in communication with the Sync Server
    class Error < Syncano::Packets::Base
      attr_accessor :error

      # Constructor for Syncano::Packets::Error object
      # @param [Hash] attributes
      def initialize(attributes)
        super(attributes)
        self.error = attributes[:error]
      end
    end
  end
end