class Syncano
  module Packets
    # Class representing call packets used in communication with the Sync Server
    class Call < Syncano::Packets::Base
      attr_accessor :message_id, :resource_name, :method_name, :data

      # Constructor for Syncano::Packets::Call object
      # @param [Hash] attributes
      def initialize(attributes)
        super(attributes)
        self.resource_name = attributes[:resource_name]
        self.method_name = attributes[:method_name]
        self.data = attributes[:data]
        self.message_id = attributes[:message_id] || rand(10**12)
      end

      # Overwritten method for preparing hash for json serialization
      # @param [Hash] options
      # @return [Hash]
      def as_json(options = {})
        {
          type: 'call',
          method: "#{resource_name}.#{method_name}",
          params: data,
          message_id: message_id.to_s
        }
      end
    end
  end
end