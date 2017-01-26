module GrapeLogging
  module Loggers
    class Response < GrapeLogging::Loggers::Base
      RESPONSE_LENGTH_EXCEEDED = "{\"alert\":\"response_length_exceeded\",\"alert_description\":\"Response length exceeded maximum allowed characters and was removed due to logging system constraints.\"}".freeze

      def parameters(_, response)
        response ? { response: serialized_response_body(response) } : {}
      end

      private
      # In some cases, response.body is not parseable by JSON.
      # For example, if you POST on a PUT endpoint, response.body is egal to """".
      # It's strange but it's the Grape behavior...
      def serialized_response_body(response)
        if response.body.first.to_s.length > 40000
          JSON.parse(RESPONSE_LENGTH_EXCEEDED)
        else
          JSON.parse(response.body.first.to_s)
        end
      rescue => e
        response.body
      end
    end
  end
end
