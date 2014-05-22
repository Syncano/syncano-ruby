class Syncano
  # Represents response from Syncano API
  class Response
    attr_reader :status, :data, :errors

    # Constructor for Syncano::Response
    # @param [Boolean] status
    # @param [Hash] data
    # @param [Array] errors
    def initialize(status = false, data = nil, errors = [])
      super()

      self.status = status
      self.data   = data
      self.errors = errors
    end

    private

    attr_writer :status, :data, :errors
  end
end