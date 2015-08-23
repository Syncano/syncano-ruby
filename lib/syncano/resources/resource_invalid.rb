module Syncano
  module Resources
    class ResourceInvalid < StandardError
      attr_accessor :resource

      def initialize(resource)
        self.resource = resource
      end

      def to_s
        "#{self.class.name} <#{resource.class.name} #{resource.errors.full_messages}>"
      end
    end
  end
end
