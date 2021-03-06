require 'syncano/active_record/scope_builder'
require 'syncano/active_record/associations'
require 'syncano/active_record/callbacks'

class Syncano
  # Scope for modules and classes integrating ActiveRecord functionality
  module ActiveRecord
    # Class for integrating ActiveRecord functionality
    class Base
      include ActiveAttr::Model
      include ActiveAttr::Dirty
      include ActiveModel::ForbiddenAttributesProtection
      include Syncano::ActiveRecord::Associations
      include Syncano::ActiveRecord::Callbacks

      attribute :id, type: Integer
      attribute :created_at, type: DateTime
      attribute :updated_at, type: DateTime

      # Gets collection with all objects
      # @return [Array]
      def self.all
        scope_builder.all
      end

      # Counts all objects
      # @return [Integer]
      def self.count
        scope_builder.count
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

      # Creates new object with specified attributes
      # @param [Hash] attributes
      # @return [Object]
      def self.create(attributes)
        new_object = self.new(attributes)
        new_object.save
        new_object
      end

      # Returns scope builder with filtering by ids newer than provided
      # @param [Integer] id
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def self.since(id)
        scope_builder.since(id)
      end

      # Returns scope builder with filtering by ids older than provided
      # @param [Integer] id
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def self.before(id)
        scope_builder.before(id)
      end

      # Returns corresponding Syncano folder
      # @return [Syncano::Resources::Folder]
      def self.folder
        begin
          folder = collection.folders.find_by_name(folder_name)
        rescue Syncano::ApiError => e
          if e.message.starts_with?('DoesNotExist')
            folder = collection.folders.create(name: folder_name)
          else
            raise e
          end
        end
        folder
      end

      # Returns scope builder with limit parameter set to parameter
      # @param [Integer] amount
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def self.limit(amount)
        scope_builder.limit(amount)
      end

      # Returns hash with filterable attributes
      # @return [HashWithIndifferentAccess]
      def self.filterable_attributes
        self._filterable_attributes ||= HashWithIndifferentAccess.new
      end

      # Returns hash with scopes
      # @return [HashWithIndifferentAccess]
      def self.scopes
        self._scopes ||= HashWithIndifferentAccess.new
      end

      # Maps syncano attributes to corresponding model attributes
      # @param [Hash] attributes
      # @return [HashWithIndifferentAccess]
      def self.map_from_syncano_attributes(attributes = {})
        mappings = HashWithIndifferentAccess.new(filterable_attributes.invert)
        HashWithIndifferentAccess[attributes.map {|k, v| [mappings[k] || k, v] }]
      end

      # Maps model attributes to corresponding syncano attributes
      # @param [Hash] attributes
      # @return [HashWithIndifferentAccess]
      def self.map_to_syncano_attributes(attributes = {})
        mappings = filterable_attributes
        HashWithIndifferentAccess[attributes.map {|k, v| [mappings[k] || k, v] }]
      end

      # Maps one model attribute to corresponding syncano attribute
      # @param [Symbol, String] attribute
      # @return [String]
      def self.map_to_syncano_attribute(attribute)
        mappings = filterable_attributes
        mappings[attribute] || attribute
      end

      # Constructor for model
      # @param [Hash] params
      def initialize(params = {})
        if params.is_a?(Syncano::Resources::DataObject)
          super(self.class.map_from_syncano_attributes(params.attributes).merge(id: params.id))
        else
          params.delete(:id)
          super(self.class.map_from_syncano_attributes(params))
        end
      end

      # Overwritten equality operator
      # @param [Object] object
      # @return [TrueClass, FalseClass]
      def ==(object)
        self.class == object.class && self.id == object.id
      end

      # Updates object with specified attributes
      # @param [Hash] attributes
      # @return [TrueClass, FalseClass]
      def update_attributes(attributes)
        self.attributes = attributes
        self.save
      end

      # Performs validations
      # @return [TrueClass, FalseClass]
      def valid?
        process_callbacks(:before_validation)
        process_callbacks(:after_validation) if result = super
        result
      end

      # Saves object in Syncano
      # @return [TrueClass, FalseClass]
      def save
        saved = false

        if valid?
          process_callbacks(:before_save)
          process_callbacks(persisted? ? :before_update : :before_create)

          data_object = persisted? ? self.class.folder.data_objects.find(id) : self.class.folder.data_objects.new
          data_object.attributes = self.class.map_to_syncano_attributes(attributes.except(:id, :created_at, :updated_at))
          data_object.save

          if data_object.saved?
            self.updated_at = data_object[:updated_at]

            if persisted?
              process_callbacks(:after_update)
            else
              self.id = data_object.id
              self.created_at = data_object[:created_at]
              process_callbacks(:after_create)
            end

            self.class.associations.values.select{ |association| association.belongs_to? }.each do |association|
              change = changes[association.foreign_key]

              if change.present?
                if change.last.nil? || association.associated_model.find(change.last).present?
                  data_object.remove_parent(change.first) unless change.first.nil?
                  data_object.add_parent(change.last) unless change.last.nil?
                end
              end
            end

            super

            process_callbacks(:after_save)
            saved = true
          end
        end

        saved
      end

      # Deletes object from Syncano
      # @return [TrueClass, FalseClass]
      def destroy
        process_callbacks(:before_destroy)
        data_object = self.class.folder.data_objects.find(id)
        data_object.destroy
        process_callbacks(:after_destroy) if data_object.destroyed
        data_object.destroyed
      end

      # Checks if object has not been saved in Syncano yet
      # @return [TrueClass, FalseClass]
      def new_record?
        !persisted?
      end

      # Checks if object has been already saved in Syncano
      # @return [TrueClass, FalseClass]
      def persisted?
        id.present?
      end

      private

      class_attribute :_filterable_attributes, :_scopes

      # Returns Syncano collection for storing Syncano::ActiveRecord objects
      # @return [Syncano::Resource::Collection]
      def self.collection
        SYNCANO_ACTIVERECORD_COLLECTION
      end

      # Returns Syncano collection for storing Syncano::ActiveRecord objects
      # @return [Syncano::Resource::Collection]
      def self.folder_name
        name.pluralize
      end

      # Setter for filterable_attributes attribute
      def self.filterable_attributes=(hash)
        self._filterable_attributes = hash
      end

      # Setter for scopes attribute
      def self.scopes=(hash)
        self._scopes = hash
      end

      # Returns scope builder for current model
      # @return [Syncano::ActiveRecord::ScopeBuilder]
      def self.scope_builder
        Syncano::ActiveRecord::ScopeBuilder.new(self)
      end

      # Defines model attribute
      # @param [Symbol] name
      # @param [Hash] options
      def self.attribute(name, options = {})
        if options[:filterable].present?
          self.filterable_attributes = HashWithIndifferentAccess.new if filterable_attributes.nil?
          filterable_attributes[name] = options.delete(:filterable)
        end
        super(name, options)
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
        Syncano::ActiveRecord::ScopeBuilder.new(object_class)
      end
    end
  end
end