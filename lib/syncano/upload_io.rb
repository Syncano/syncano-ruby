module Syncano
  class UploadIO < Faraday::UploadIO
    def initialize(path)
      super path, File.mime_type?(File.new(path))
    end
  end
end