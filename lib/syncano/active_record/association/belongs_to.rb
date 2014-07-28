require 'syncano/active_record/association/base'

class Syncano
  module ActiveRecord
    module Association
      # Class for belongs to association
      class BelongsTo < Syncano::ActiveRecord::Association::Base
        attr_reader :associated_model, :foreign_key, :source_model

        # Constructor for belongs_to association
        # @param [Class] source_model
        # @param [Symbol] name
        def initialize(source_model, name)
          super
          self.foreign_key = associated_model.name.foreign_key
        end

        # Checks if association is belongs_to type
        # @return [TrueClass]
        def belongs_to?
          true
        end

        private

        attr_writer :associated_model, :foreign_key, :source_model
      end
    end
  end
end