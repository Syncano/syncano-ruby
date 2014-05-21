class Syncano
  module Resources
    class Subscription < ::Syncano::Resources::Base

      private

      self.crud_class_methods = [:all]
      self.crud_instance_methods = []
    end
  end
end