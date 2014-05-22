class Syncano
  module Resources
    # Role resource
    class Role < ::Syncano::Resources::Base
      private

      self.crud_class_methods = [:all]
      self.crud_instance_methods = []
    end
  end
end