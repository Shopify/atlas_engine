# typed: true
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    module AddressParsingHelper
      extend T::Sig

      sig { returns(Constants) }
      def address_constants
        @address_constants ||= T.let(
          Constants.instance,
          T.nilable(Constants),
        )
      end

      sig { params(token: T.nilable(String)).returns(T::Boolean) }
      def directional?(token)
        return false if token.blank?

        downcased = token.downcase
        english = address_constants.translations_fr_en[downcased.to_sym] || downcased

        address_constants.known?(:directionals, english)
      end

      sig { params(token: T.nilable(String)).returns(T::Boolean) }
      def street_suffix?(token)
        return false if token.blank?

        downcased = token.downcase
        english = address_constants.translations_fr_en[downcased.to_sym] || downcased

        address_constants.known?(:street_suffixes, english)
      end
    end
  end
end
