# typed: strict
# frozen_string_literal: true

module AtlasEngine
  class CodedErrors
    ErrorCode = T.type_alias { T.any(Symbol, String) }

    class << self
      extend T::Sig

      sig { params(code: ErrorCode, message: String).void }
      def error(code, message)
        error = CodedError.new(code, message)
        error_constant_name = code.to_s.underscore.upcase

        raise "#{code} error is already defined" if const_defined?(error_constant_name)

        const_set(error_constant_name, error)
      end
    end

    class CodedError < StandardError
      extend T::Sig

      sig { returns(ErrorCode) }
      attr_reader :code

      sig { params(code: ErrorCode, message: String).void }
      def initialize(code, message)
        @code = code
        super(message)
      end
    end
    private_constant :CodedError
  end
end
