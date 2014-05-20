class Syncano
  module Packets
    class Call < Packets::Base

      def as_json(options = {})
        {
          type: 'call',
          method: "#{resource_name}.#{method_name}",
          params: data
        }
      end
    end
  end
end