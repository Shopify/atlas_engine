# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module LogBase
    include Kernel
    extend T::Sig

    TEST_TIMESTAMP = T.let("timestamp", String)

    sig { params(level: Symbol, message: String, additional_params: T::Hash[Symbol, T.untyped]).void }
    def log_message(level, message, additional_params = {})
      params = {
        messages: [{
          level: level,
          source: self.class.name,
          message: message,
          timestamp: time,
        }.merge(additional_params)],
      }

      Rails.logger.send(level, params)
    end

    sig { returns(String) }
    def time
      return TEST_TIMESTAMP if Rails.env.test?

      Time.current.utc.to_fs
    end
  end
end
