require 'syncano/model/scope_builder'
require 'syncano/model/associations'
require 'syncano/model/callbacks'

module Syncano
  # Scope for modules and classes integrating ActiveRecord functionality
  module Model
    # Class for integrating ActiveRecord functionality
    class Base
      include ActiveAttr::Model
      include ActiveAttr::Dirty

      include ActiveModel::ForbiddenAttributesProtection
      include Syncano::Model::Associations
      include Syncano::Model::Callbacks

      attribute :id, type: Integer
      attribute :created_at, type: DateTime
      attribute :updated_at, type: DateTime

      # Constructor for model
      # @param [Hash] params
      def initialize(params = {})
        if params.is_a?(Syncano::Resources::Object)
          self.syncano_object = params
          self.attributes = syncano_object_merged_attributes
        else
          self.syncano_object = self.class.syncano_class.objects.new
          self.attributes = params
        end
      end

      # Gets collection with all objects
      # @return [Array]
      def self.all
        scope_builder.all
      end

      # Returns first object or collection of first x objects
      # @param [Integer] amount
      # @return [Object, Array]
      def self.first(amount = nil)
        scope_builder.first(amount)
      end

      # Returns last object or collection of last x objects
      # @param [Integer] amount
      # @return [Object, Array]
      def self.last(amount = nil)
        scope_builder.last(amount)
      end

      # Returns scope builder with condition passed as arguments
      # @param [String] condition
      # @param [Array] params
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def self.where(condition, *params)
        scope_builder.where(condition, *params)
      end

      # Returns scope builder with order passed as first argument
      # @param [String] order
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def self.order(order)
        scope_builder.order(order)
      end

      # Returns one object found by id
      # @param [Integer] id
      # @return [Object]
      def self.find(id)
        scope_builder.find(id)
      end

      def reload!
        syncano_object.reload!
        self.attributes = syncano_object_merged_attributes
        self
      end

      # Creates new object with specified attributes
      # @param [Hash] attributes
      # @return [Object]
      def self.create(attributes)
        new_object = self.new(attributes)
        new_object.save
        new_object
      end

      # Saves object in Syncano
      # @return [TrueClass, FalseClass]
      def save
        if valid?
          was_persisted = persisted?

          process_callbacks(:before_save)
          process_callbacks(was_persisted ? :before_update : :before_create)

          syncano_object.custom_attributes = attributes_to_sync
          syncano_object.save
          self.attributes = syncano_object_merged_attributes

          process_callbacks(was_persisted ? :after_update : :after_create)
          process_callbacks(:after_save)
        end
      end

      def self.syncano_class
        syncano_class
      end

      # Updates object with specified attributes
      # @param [Hash] attributes
      # @return [TrueClass, FalseClass]
      def update_attributes(attributes)
        self.attributes = attributes
        self.save
      end

      # Returns scope builder with limit parameter set to parameter
      # @param [Integer] amount
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def self.limit(amount)
        scope_builder.limit(amount)
      end

      # Returns hash with scopes
      # @return [HashWithIndifferentAccess]
      def self.scopes
        self._scopes ||= HashWithIndifferentAccess.new
      end

      # Overwritten equality operator
      # @param [Object] object
      # @return [TrueClass, FalseClass]
      def ==(object)
        self.class == object.class && id == object.id
      end

      # Performs validations
      # @return [TrueClass, FalseClass]
      def valid?
        process_callbacks(:before_validation)
        process_callbacks(:after_validation) if result = super
        result
      end

      # Deletes object from Syncano
      # @return [TrueClass, FalseClass]
      def destroy
        process_callbacks(:before_destroy)
        syncano_object.destroy
        process_callbacks(:after_destroy) if syncano_object.destroyed?
      end

      def destroyed?
        syncano_object.destroyed?
      end

      # Checks if object has not been saved in Syncano yet
      # @return [TrueClass, FalseClass]
      def new_record?
        !persisted?
      end

      # Checks if object has been already saved in Syncano
      # @return [TrueClass, FalseClass]
      def persisted?
        !syncano_object.new_record?
      end

      private

      class_attribute :syncano_class
      attr_accessor :syncano_object

      class_attribute :_scopes

      # Setter for scopes attribute
      def self.scopes=(hash)
        self._scopes = hash
      end

      # Returns scope builder for current model
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def self.scope_builder
        Syncano::Model::ScopeBuilder.new(self)
      end

      # Defines model scope
      # @param [Symbol] name
      # @param [Proc] procedure
      def self.scope(name, procedure)
        scopes[name] = procedure
      end

      # Overwritten method_missing for handling calling defined scopes
      # @param [String] name
      # @param [Array] args
      def self.method_missing(name, *args)
        if scopes[name].nil?
          super
        else
          scope_builder.send(name.to_sym, *args)
        end
      end

      # Returns scope builder for specified class
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def scope_builder(object_class)
        Syncano::Model::ScopeBuilder.new(object_class)
      end

      def attributes_to_sync
        attributes_names = self.class.attributes_to_sync
        attributes.select{ |name, value| attributes_names.include?(name.to_sym) }
      end

      def self.attributes_to_sync
        syncano_class.schema.collect{ |attribute| attribute[:name].to_sym }
      end

      def syncano_object_merged_attributes
        syncano_object.attributes.except(:custom_attributes).merge(syncano_object.custom_attributes)
      end

      def self.inherited(child_class)
        # Load schema and generate attributes
        child_class_name = child_class.name.demodulize.tableize.singularize
        syncano_class = MODEL_SCHEMA.find{ |syncano_class| syncano_class.name == child_class_name }

        syncano_class.schema.each do |attribute_schema|
          attribute attribute_schema['name'], type: String
        end

        child_class.syncano_class = syncano_class

        super
      end
    end
  end
end