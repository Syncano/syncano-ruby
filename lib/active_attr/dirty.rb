require 'active_support'
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
      def attribute!(name, options={})
        super(name, options)
        define_method("#{name}=") do |value|
          send("#{name}_will_change!") unless value == read_attribute(name)
          super(value)
        end
      end
    end

    # Overwritten constructor
    # @param [Hash] attributes
    # @param [Hash] options
    def initialize(attributes = nil, options = {})
      super(attributes, options)
      (@changed_attributes || {}).clear unless new_record?
    end

    # Overwritten save method
    def save
      @previously_changed = changes
      @changed_attributes.clear
    end
  end
end