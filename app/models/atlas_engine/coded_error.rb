# typed: strict
# frozen_string_literal: true

module AtlasEngine
  class CodedError < StandardError
    extend T::Sig
    ErrorCode = T.type_alias { T.any(Symbol, String) }

    sig { returns(ErrorCode) }
    attr_reader :code

    sig { params(code: ErrorCode, message: String).void }
    def initialize(code, message)
      @code = code
      super(message)
    end
  end
end
