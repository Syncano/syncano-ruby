require 'active_attr/typecasting/big_decimal_typecaster'
require 'active_attr/typecasting/boolean'
require 'active_attr/typecasting/boolean_typecaster'
require 'active_attr/typecasting/date_time_typecaster'
require 'active_attr/typecasting/date_typecaster'
require 'active_attr/typecasting/float_typecaster'
require 'active_attr/typecasting/integer_typecaster'
require 'active_attr/typecasting/object_typecaster'
require 'active_attr/typecasting/string_typecaster'
require 'active_attr/typecasting/hash_typecaster'
require 'active_attr/typecasting/unknown_typecaster_error'

module ActiveAttr
  module Typecasting
    remove_const(:TYPECASTER_MAP) if defined?(TYPECASTER_MAP)

    TYPECASTER_MAP = {
      BigDecimal => BigDecimalTypecaster,
      Boolean    => BooleanTypecaster,
      Date       => DateTypecaster,
      DateTime   => DateTimeTypecaster,
      Float      => FloatTypecaster,
      Integer    => IntegerTypecaster,
      Object     => ObjectTypecaster,
      String     => StringTypecaster,
      Hash       => HashTypecaster
    }.freeze
  end
end
