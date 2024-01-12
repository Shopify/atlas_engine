# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module LocaleFormatHelper
    class << self
      extend T::Sig

      sig { params(locale: T.nilable(String)).returns(T.nilable(String)) }
      def format_locale(locale)
        return if locale.blank?

        resolve_supported_locale(locale) || locale.to_s
      end

      private

      SUPPORTED_LOCALE_MAP = T.let(
        {
          DA: "da",
          DE: "de",
          EN: "en",
          ES: "es",
          FR: "fr",
          IT: "it",
          JA: "ja",
          NL: "nl",
          "PT-BR": "pt-BR",
          PT: "pt",
        },
        T::Hash[T.untyped, T.untyped],
      )

      sig { params(locale: String).returns(T.nilable(String)) }
      def resolve_supported_locale(locale)
        SUPPORTED_LOCALE_MAP[locale.to_sym]
      end
    end
  end
end
