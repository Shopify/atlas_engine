# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Errors
    class LocaleUnsupportedError < GraphQL::ExecutionError
      def to_h
        super.merge(
          "extensions" => {
            "code" => "LOCALE_UNSUPPORTED",
            "attribute" => "locale",
          },
        )
      end
    end
  end
end
