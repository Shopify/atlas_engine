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
          # normalizes Arabic characters
          .tr("آ", "ا")
          .tr("أ", "ا")
          .tr("إ", "ا")
          .tr("ئ", "ي")
          .tr("ة", "ه")
          .tr("ى", "ي")
          # removes Arabic stretching characters and diacritics
          .gsub(/[\u064B|\u064C|\u064D|\u064E|\u064F|\u0650|\u0651|\u0652|\u0640]/, "")
          # TODO: Strip hyphens for USPS not zip
          .gsub(/[!@%&"'*,.();:]/, "")
          .downcase
          .tr(T.unsafe(AtlasEngine::ValidationTranscriber::Constants.instance).with_diacritics,
            T.unsafe(AtlasEngine::ValidationTranscriber::Constants.instance).without_diacritics)
      end
    end
  end
end
