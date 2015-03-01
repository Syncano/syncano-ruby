require 'syncano/model/associations/belongs_to'
require 'syncano/model/associations/has_many'
require 'syncano/model/associations/has_one'

module Syncano
  module Model
    # Module with associations functionality for Syncano::Model
    module Associations
      extend ActiveSupport::Concern

      included do
        private

        class_attribute :_associations
      end

      # Class methods for Syncano::Model::Associations module
      module ClassMethods
        # Lists hash with associations
        # @return [HashWithIndifferentAccess]
        def associations
          self._associations ||= HashWithIndifferentAccess.new
        end

        private

        # Defines belongs_to association
        # @param [Symbol] object_name
        def belongs_to(object_name, options = {})
          association = Syncano::Model::Association::BelongsTo.new(self, object_name, options)
          associations[object_name] = association

          define_method(object_name) do
            association = self.class.associations[object_name]
            id = send(association.foreign_key)
            scope = scope_builder(association.associated_model).find(id)
          end

          define_method("#{object_name}=") do |object|
            association = self.class.associations[object_name]

            unless object.is_a?(association.associated_model)
              raise "Object should be an instance of #{association.associated_model} class"
            end
            send("#{association.foreign_key}=", object.try(:id))
          end
        end

        # Defines has_one association
        # @param [Symbol] object_name
        def has_one(object_name, options = {})
          association = Syncano::Model::Association::HasOne.new(self, object_name, options)
          associations[object_name] = association

          define_method(object_name) do
            association = self.class.associations[object_name]

            scope = scope_builder.new(association.associated_model)
            scope.where("#{association.foreign_key} = ?", id).first if id.present?
          end

          define_method("#{object_name}=") do |object|
            association = self.class.associations[object_name]

            unless object.is_a?(association.associated_model)
              raise "Object should be an instance of #{association.associated_model} class"
            end

            object.send("#{association.foreign_key}=", id)
            object.save unless object.new_record?
            object
          end

          define_method("build_#{object_name}") do |attributes = {}|
            association = self.class.associations[object_name]
            association.associated_model.new(attributes)
          end

          define_method("create_#{object_name}") do |attributes = {}|
            association = self.class.associations[object_name]
            association.associated_model.create(attributes)
          end
        end

        # Defines has_many association
        # @param [Symbol] collection_name
        def has_many(collection_name, options = {})
          association = Syncano::Model::Association::HasMany.new(self, collection_name, options)
          associations[collection_name] = association

          define_method(collection_name) do
            association = self.class.associations[collection_name]
            association.scope_builder(self)
          end

          define_method("#{collection_name}=") do |collection|
            association = self.class.associations[collection_name]
            objects_ids = {}

            collection.each do |object|
              "Object should be an instance of #{association.associated_model} class" unless object.is_a?(association.associated_model)
              objects_ids[object.id] = true
            end

            send(collection_name).all.each do |object|
              unless objects_ids[object.id]
                object.send("#{association.foreign_key}=", nil)
                object.save unless object.new_record?
              end
            end

            collection.each do |object|
              object.send("#{association.foreign_key}=", id)
              object.save unless object.new_record?
            end
          end
        end
      end
    end
  end
end