module Syncano
  module Resources
    module AssociationsConcern
      extend ActiveSupport::Concern

      included do
        private

        attr_accessor :association_paths
      end

      module ClassMethods
      end

      private

      def initialize_associations(attributes)
        self.association_paths = HashWithIndifferentAccess.new

        if attributes[:links].present?
          attributes[:links].keys.each do |key|
            association_paths[key] = self.class.send(:remove_version_from_path, attributes[:links][key])
          end
        end
      end

      def has_many_association(name)
        # TODO Implement QueryBuilders without scope parameters and adding objects to the association
        raise(Syncano::Error.new('record not saved')) if new_record?

        resource_class = self.class.map_collection_name_to_resource_class(name)
        scope_parameters = resource_class.extract_scope_parameters(association_paths[name])

        ::Syncano::QueryBuilder.new(connection, resource_class, scope_parameters)
      end

      def belongs_to_association(name)
        resource_class = self.class.map_member_name_to_resource_class(name)
        scope_parameters = resource_class.extract_scope_parameters(association_paths[name])
        pk = resource_class.extract_primary_key(association_paths[name])

        ::Syncano::QueryBuilder.new(connection, resource_class, scope_parameters).find(pk)
      end
    end
  end
end