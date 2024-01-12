# typed: false
# frozen_string_literal: true

module AtlasEngine
  module LogAssertionHelper
    def assert_log_append(level, source, message, additional_params = {})
      Rails.logger.expects(level).with({
        messages: [{
          level: level,
          source: source,
          message: message,
          timestamp: AtlasEngine::LogBase::TEST_TIMESTAMP,
        }.merge(additional_params)],
      })
    end

    def refute_log_append(level, source, message)
      Rails.logger.expects(level).with(messages: [{
        level: level,
        source: source,
        message: message,
        timestamp: AtlasEngine::LogBase::TEST_TIMESTAMP,
      }]).never
    end
  end
end
