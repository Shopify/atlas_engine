# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module LogHelper
    sig { params(level: Symbol, message: String, additional_params: T::Hash[Symbol, T.untyped]).void }
    def log_message(level, message, additional_params = {}); end
  end
end
