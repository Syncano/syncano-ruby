class Syncano
  # General errors
  class BaseError < RuntimeError
  end

  # Class represeting errors returned by the Syncano API
  class ApiError < BaseError
  end

  # Class representing errors during connections
  class ConnectionError < BaseError
  end
end