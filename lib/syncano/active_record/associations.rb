require 'syncano/active_record/association/belongs_to'
require 'syncano/active_record/association/has_many'
require 'syncano/active_record/association/has_one'

class Syncano
  module ActiveRecord
    # Module with associations functionality for Syncano::ActiveRecord
    module Associations
      extend ActiveSupport::Concern

      included do
        private

        class_attribute :_associations
      end

      # Class methods for Syncano::ActiveRecord::Associations module
      module ClassMethods
        # Lists hash with associations
        # @return [HashWithIndifferentAccess]
        def associations
          self._associations ||= HashWithIndifferentAccess.new
        end

        private

        # Setter for associations
        def associations=(hash)
          self._associations = hash
        end

        # Defines belongs_to association
        # @param [Symbol] object_name
        def belongs_to(object_name)
          association = Syncano::ActiveRecord::Association::BelongsTo.new(self, object_name)
          associations[object_name] = association

          attribute association.foreign_key
          validates association.foreign_key, numericality: { only_integer: true, allow_nil: true }

          define_method(object_name) do
            id = send(self.class.associations[object_name].foreign_key)
            scope = scope_builder(self.class.associations[object_name].associated_model)
            scope.find(id) if id.present?
          end

          define_method("#{object_name}=") do |object|
            unless object.is_a?(self.class.associations[object_name].associated_model)
              "Object should be an instance of #{self.class.associations[object_name].associated_model} class"
            end
            send("#{self.class.associations[object_name].foreign_key}=", object.try(:id))
          end
        end

        # Defines has_one association
        # @param [Symbol] object_name
        def has_one(object_name)
          association = Syncano::ActiveRecord::Association::HasOne.new(self, object_name)
          associations[object_name] = association

          define_method(object_name) do
            scope = scope_builder(self.class.associations[object_name].associated_model)
            scope.by_parent_id(id).first if id
          end

          define_method("#{object_name}=") do |object|
            object.send("#{self.class.associations[object_name].foreign_key}=", id)
            object.save unless object.new_record?
            object
          end

          define_method("build_#{object_name}") do |attributes = {}|
            self.class.associations[object_name].associated_model.new(attributes)
          end

          define_method("create_#{object_name}") do |attributes = {}|
            self.class.associations[object_name].associated_model.create(attributes)
          end
        end

        # Defines has_many association
        # @param [Symbol] collection_name
        def has_many(collection_name)
          association = Syncano::ActiveRecord::Association::HasMany.new(self, collection_name)
          associations[collection_name] = association

          define_method(collection_name) do
            self.class.associations[collection_name].scope_builder(self)
          end

          define_method("#{collection_name}=") do |collection|
            association = self.class.associations[collection_name]

            collection.each do |object|
              "Object should be an instance of #{association.associated_class} class" unless object.is_a?(association.associated_class)
            end

            send(collection_name).all.each do |object|
              object.send("#{association.foreign_key}=", nil)
              object.save
            end

            collection.each do |object|
              object.send("#{association.foreign_key}=", id)
              object.save
            end
          end
        end
      end
    end
  end
end