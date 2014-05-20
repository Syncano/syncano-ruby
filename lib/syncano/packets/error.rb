class Syncano
  module Packets
    class Error < Syncano::Packets::Base
      attr_accessor :error

      def initialize(attributes)
        super(attributes)
        self.error = attributes[:error]
      end
    end
  end
end