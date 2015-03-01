require 'syncano/model/associations/base'

module Syncano
  module Model
    module Association
      # Class for has many association
      class HasMany < Syncano::Model::Association::Base
        attr_reader :associated_model, :foreign_key, :source_model

        # Checks if association is has_many type
        # @return [TrueClass]
        def has_many?
          true
        end

        # Returns new associaton object with source object set
        # @param [Object] source
        # @return [Syncano::ActiveRecord::Association::HasMany]
        def scope_builder(source)
          association = self.dup
          association.source = source
          association
        end

        # Builds new associated object
        # @return [Object]
        def build(attributes = {})
          new(attributes)
        end

        def new(attributes = {})
          associated_model.new(attributes.merge(foreign_key => source.id))
        end

        # Creates new associated object
        # @return [Object]
        def create(attributes = {})
          associated_model.create(attributes.merge(foreign_key => source.id))
        end

        # Adds object to the related collection by setting foreign key
        # @param [Object] object
        # @return [Object]
        def <<(object)
          "Object should be an instance of #{associated_model} class" unless object.is_a?(associated_model)

          object.send("#{foreign_key}=", source.id)
          object.save unless object.new_record?
          object
        end

        protected

        attr_accessor :source

        private

        attr_writer :associated_model, :foreign_key, :source_model

        # Overwritten method_missing for handling scope methods
        # @param [String] name
        # @param [Array] args
        def method_missing(name, *args)
          scope_builder = Syncano::Model::ScopeBuilder.new(associated_model).where("#{foreign_key} = ?", source.id)

          if scope_builder.respond_to?(name) || !source.scopes[name].nil?
            scope_builder.send(name, *args)
          else
            super
          end
        end
      end
    end
  end
end