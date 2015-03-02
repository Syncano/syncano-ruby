module Syncano
  class Scope
    attr_accessor :connection, :scope_parameters

    def initialize(connection, scope_parameters)
      self.connection = connection
      self.scope_parameters = scope_parameters
    end
  end
end