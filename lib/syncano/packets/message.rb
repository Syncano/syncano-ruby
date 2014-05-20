class Syncano
  module Packets
    class Message < Syncano::Packets::Base
      attr_accessor :id, :source, :data

      def initialize(attributes)
        super(attributes)
        self.id = attributes[:id]
        self.source = attributes[:source]
        self.data = attributes[:data]
      end

      def notification?
        true
      end

      def message?
        true
      end
    end
  end
end