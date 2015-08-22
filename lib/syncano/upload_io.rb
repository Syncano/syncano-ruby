module Syncano
  class UploadIO < Faraday::UploadIO
    def initialize(path)
      super path, 'text/plain'
    end
  end
end