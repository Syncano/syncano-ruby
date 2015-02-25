require 'syncano/active_record/scope_builder'

class Syncano
  module Model
    # Module with associations functionality for Syncano::ActiveRecord
    module Association
      # Base class for all associations
      class Base
        # Constructor for association
        # @param [Class] source_model
        # @param [Symbol] name
        def initialize(source_model, name)
          self.source_model = source_model
          self.associated_model = name.to_s.classify.constantize
          self.foreign_key = source_model.name.foreign_key
        end

        # Checks if association is belongs_to type
        # @return [FalseClass]
        def belongs_to?
          false
        end

        # Checks if association is has_one type
        # @return [FalseClass]
        def has_one?
          false
        end

        # Checks if association is has_many type
        # @return [FalseClass]
        def has_many?
          false
        end
      end
    end
  end
end