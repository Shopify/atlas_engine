# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    module Formatter
      extend T::Sig

      sig { params(text: T.nilable(String)).returns(T.nilable(String)) }
      def strip_trailing_punctuation(text)
        text.presence&.sub(/[\s,\-]+$/, "")
      end

      sig { params(haystack: String, needle: String).returns(String) }
      def strip_word(haystack, needle)
        string = haystack.sub(/[\s](#{Regexp.escape(needle)})([\s]|$)/i, " ").strip
        string = string.sub(/[\s,](#{Regexp.escape(needle)})([\s,]|$)/i, "").strip
        string = strip_trailing_punctuation(string)
        string || ""
      end

      sig do
        params(
          address1: String,
          address2: String,
          city: String,
          province_code: String,
          zip: String,
          country_code: String,
          phone: String,
        ).returns(AddressValidation::Address)
      end
      def build_address(address1: "", address2: "", city: "", province_code: "", zip: "", country_code: "", phone: "")
        AddressValidation::Address.new(
          address1: address1,
          address2: address2,
          city: city,
          province_code: province_code,
          zip: zip,
          country_code: country_code,
          phone: phone,
        )
      end
    end
  end
end
