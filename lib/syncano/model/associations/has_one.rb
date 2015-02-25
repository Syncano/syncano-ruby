require 'syncano/active_record/association/base'

class Syncano
  module Model
    module Association
      # Class for has one association
      class HasOne < Syncano::ActiveRecord::Association::Base
        attr_reader :associated_model, :foreign_key, :source_model

        # Checks if association is has_one type
        # @return [TrueClass]
        def has_one?
          true
        end

        private

        attr_writer :associated_model, :foreign_key, :source_model
      end
    end
  end
end