module GrapeLogging
  module Loggers
    class Response < GrapeLogging::Loggers::Base
      MAX_RESPONSE_LENGTH = 180_000
      MAX_RESPONSE_BODY = {
        'alert': 'response_length_exceeded',
        'alert_description':
          'Response length exceeded maximum allowed characters and was removed due to logging system constraints.'
      }.freeze

      def parameters(_, response)
        response ? { response: serialized_response_body(response) } : {}
      end

      private

      # In some cases, response.body is not parseable by JSON.
      # For example, if you POST on a PUT endpoint, response.body is egal to """".
      # It's strange but it's the Grape behavior...
      def serialized_response_body(response)
        body = if response.body.respond_to?(:body) # Rails responses
                 response.body.body
               else # Grape responses
                 response.body.first
               end

        serialize_body(body)
      rescue StandardError
        response.body
      end

      def serialize_body(body)
        return MAX_RESPONSE_BODY if body.length > MAX_RESPONSE_LENGTH

        JSON.parse(body)
      end
    end
  end
end
