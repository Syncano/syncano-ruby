class Syncano
  module Packets
    class Ping < Syncano::Packets::Base
      def ping?
        true
      end
    end
  end
end