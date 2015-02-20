require 'active_support/concern'
require 'active_model/dirty'
require 'active_attr'

# Overwritting ActiveAttr module
module ActiveAttr
  # Overwritting ActiveAttr::Dirty module
  module Dirty
    extend ActiveSupport::Concern
    include ActiveModel::Dirty

    # Class methods for ActiveAttr::Dirty module
    module ClassMethods
      # Overwritten attribute! method
      # @param [Symbol] name
      # @param [Hash] options
      def attribute!(name, options = {})
        super(name, options)
        define_method("#{name}=") do |value|
          send("#{name}_will_change!") unless value == read_attribute(name)
          super(value)
        end
      end
    end
  end
end
