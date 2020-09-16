module GrapeLogging
  module Loggers
    class Response < GrapeLogging::Loggers::Base
      MAX_RESPONSE_LENGTH = 180_000
      RESPONSE_LENGTH_EXCEEDED = "{\"alert\":\"response_length_exceeded\",\"alert_description\":\"Response length exceeded maximum allowed characters and was removed due to logging system constraints.\"}".freeze

      def parameters(_, response)
        response ? { response: serialized_response_body(response) } : {}
      end

      private
      # In some cases, response.body is not parseable by JSON.
      # For example, if you POST on a PUT endpoint, response.body is egal to """".
      # It's strange but it's the Grape behavior...
      def serialized_response_body(response)
        if response.body.body.length > MAX_RESPONSE_LENGTH
          JSON.parse(RESPONSE_LENGTH_EXCEEDED)
        else
          JSON.parse(response.body.body)
        end
      rescue StandardError
        response.body
      end
    end
  end
end
