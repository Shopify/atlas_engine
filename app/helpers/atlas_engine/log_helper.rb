# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module LogHelper
    T.unsafe(self).include(AtlasEngine.log_base.constantize)
    extend T::Sig

    sig { params(message: String, additional_params: T::Hash[Symbol, T.untyped]).void }
    def log_info(message, additional_params = {})
      log_message(:info, message, additional_params)
    end

    sig { params(message: String, additional_params: T::Hash[Symbol, T.untyped]).void }
    def log_warn(message, additional_params = {})
      log_message(:warn, message, additional_params)
    end

    sig { params(message: String, additional_params: T::Hash[Symbol, T.untyped]).void }
    def log_error(message, additional_params = {})
      log_message(:error, message, additional_params)
    end
  end
end
