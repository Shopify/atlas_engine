# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Services
    module ServiceHelper
      def handle_metrics(request_type, country_code, using_session_token)
        result = yield

        ActiveSupport::Notifications.instrument("atlas.service.events", {
          request_type: request_type,
          country_code: country_code,
          using_session_token: using_session_token,
          result: result,
        })

        result
      end
    end
  end
end
