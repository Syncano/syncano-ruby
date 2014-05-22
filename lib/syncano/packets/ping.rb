class Syncano
  module Packets
    # Class representing ping packets used in communication with the Sync Server
    class Ping < Syncano::Packets::Base
      # Returns true if is a ping packet
      # @return [TrueClass, FalseClass]
      def ping?
        true
      end
    end
  end
end