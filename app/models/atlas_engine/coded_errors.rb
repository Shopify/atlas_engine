# typed: strict
# frozen_string_literal: true

module AtlasEngine
  class CodedErrors
    ErrorCode = T.type_alias { T.any(Symbol, String) }

    class << self
      extend T::Sig

      sig { params(code: ErrorCode, message: String).returns(CodedError) }
      def error(code, message)
        CodedError.new(code, message)
      end
    end
  end
end
