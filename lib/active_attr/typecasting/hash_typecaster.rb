require 'active_support/core_ext/hash/indifferent_access'

module ActiveAttr
  module Typecasting
    # Typecasts an Object to a HashWithInddifferentAccess
    #
    # @example Usage
    #   typecaster = HashTypecaster.new
    #   typecaster.call([[:foo, :bar]]) #=> { foo: :bar }
    #
    # @since 0.5.0
    class HashTypecaster
      # Typecasts an object to a HashWithInddifferentAccess
      #
      # Attempts to convert using #to_h.
      #
      # @example Typecast an Array
      #   typecaster.call([[:foo, :bar]]) #=> { foo: :bar }
      #
      # @param [Object, #to_h] value The object to typecast
      #
      # @return [HashWithInddifferentAccess] The result of typecasting
      #
      # @since 0.5.0
      def call(value)
        if value.respond_to? :to_h
          HashWithIndifferentAccess.new(value.to_h)
        else
          HashWithIndifferentAccess.new
        end
      end
    end
  end
end
