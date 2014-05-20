class Syncano
  module Packets
    class Base
      attr_accessor :timestamp, :data, :resource_name, :method_name

      def initialize(resource_name, method_name, data)
        self.resource_name = resource_name
        self.method_name = method_name
        self.data = data
      end

      def self.instantize_packet(type, *args)
        mapping  = {
          ping: Syncano::Packets::Ping
        }

        mapping[type.to_sym].new(args)
      end
    end
  end
end