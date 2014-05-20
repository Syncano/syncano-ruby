class Syncano
  module Packets
    class Call < Syncano::Packets::Base
      attr_accessor :message_id, :resource_name, :method_name, :data

      def initialize(attributes)
        super(attributes)
        self.resource_name = attributes[:resource_name]
        self.method_name = attributes[:method_name]
        self.data = attributes[:data]
        self.message_id = attributes[:message_id] || rand(10**12)
      end

      def as_json(options = {})
        {
          type: 'call',
          method: "#{resource_name}.#{method_name}",
          params: data,
          message_id: message_id
        }
      end
    end
  end
end