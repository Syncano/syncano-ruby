module Syncano
  module Resources
    module AssociationsConcern
      extend ActiveSupport::Concern

      included do
        private

        attr_accessor :association_paths
      end

      module ClassMethods
        private
      end

      private

      def initialize_associations(attributes)
        self.association_paths = HashWithIndifferentAccess.new

        attributes[:links].keys.each do |key|
          association_paths[key] = self.class.send(:remove_version_from_path, attributes[:links][key])
        end
      end

      def has_many_association(name)
        resource_class = self.class.map_name_to_resource_class(name)
        scope_parameters = resource_class.extract_scope_parameters(association_paths[name])

        ::Syncano::QueryBuilder.new(connection, resource_class, scope_parameters)
      end

      def belongs_to_association(name)
        resource_class = "::Syncano::Resources::#{name.camelize}".constantize
        ::Syncano::QueryBuilder.new(connection, resource_class)
      end
    end
  end
end