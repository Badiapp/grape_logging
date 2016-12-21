module GrapeLogging
  module Loggers
    class FilterParameters < GrapeLogging::Loggers::Base
      AD_PARAMS = 'action_dispatch.request.parameters'.freeze

      def initialize(filter_parameters = nil, replacement = '[FILTERED]', exceptions = %w(controller action format))
        @filter_parameters = filter_parameters || (defined?(Rails.application) ? Rails.application.config.filter_parameters : [])
        @replacement = replacement
        @exceptions = exceptions
      end

      def parameters(request, _)
        { params: safe_parameters(request) }
      end

      private

      def parameter_filter
        @parameter_filter ||= ActionDispatch::Http::ParameterFilter.new(@filter_parameters)
      end

      def safe_parameters(request)
        # Now this logger can work also over Rails requests
        return clean_parameters(request.env[AD_PARAMS] || {}) if request.params.empty?
        clean_parameters(request.params.clone)
      end

      def clean_parameters(parameters)
        parameter_filter.filter(parameters).except(*@exceptions)
      end
    end
  end
end
