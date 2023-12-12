# typed: strict
# frozen_string_literal: true

module AtlasEngine
  class CodedErrors
    ErrorCode = T.type_alias { T.any(Symbol, String) }

    class << self
      extend T::Sig

      sig { params(code: ErrorCode, message: String).returns(CodedError) }
      def error(code, message)
        error = CodedError.new(code, message)
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
