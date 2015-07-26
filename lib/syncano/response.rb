module Syncano
  class Response
    class << self
      def handle(raw_response)
        code = unify_code(raw_response)

        case code
          when Status.no_content
          when Status.successful
            parse_response raw_response
          when Status.not_found
            raise NotFound.new(raw_response.env.url, raw_response.env.method)
          when Status.client_error # TODO figure out if we want to raise an exception on not found or not
            raise ClientError.new raw_response.body, raw_response
          when Status.server_error
            raise ServerError.new raw_response.body, raw_response
          else
            raise UnsupportedStatusError.new raw_response
        end
      end

      def parse_response(raw_response)
        JSON.parse(raw_response.body)
      end

      def unify_code(raw_response)
        raw_response.status.code
      end
    end

    class Status
      class << self
        def successful
          ->(code) { (200...300).include? code }
        end

        def client_error
          ->(code) { (400...500).include? code }
        end

        def no_content
          ->(code) { code == 204 }
        end

        def server_error
          ->(code) { code >= 500 }
        end

        def not_found
          ->(code) { code == 404 }
        end
      end
    end
  end
end