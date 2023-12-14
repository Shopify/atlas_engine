# typed: false
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class StreetParser
      def parse(street:, locale: nil)
        lang = Worldwide.locale(code: locale || I18n.locale).language_subtag.to_s.downcase

        if "fr" == lang
          FrenchStreetParser.new.parse(street: street)
        else
          EnglishStreetParser.new.parse(street: street)
        end
      end
    end
  end
end
