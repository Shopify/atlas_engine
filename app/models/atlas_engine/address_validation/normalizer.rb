# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Normalizer
      extend T::Sig

      sig do
        params(
          string: String,
        ).returns(String)
      end
      def normalize(string)
        string
          .gsub("Æ", "AE")
          .gsub("Œ", "OE")
          .gsub("æ", "ae")
          .gsub("œ", "oe")
          .gsub("  ", " ")
          # TODO: Strip hyphens for USPS not zip
          .gsub(/[!@%&"'*,.();:]/, "")
          .downcase
          .tr(T.unsafe(AtlasEngine::ValidationTranscriber::Constants.instance).with_diacritics,
            T.unsafe(AtlasEngine::ValidationTranscriber::Constants.instance).without_diacritics)
      end
    end
  end
end
