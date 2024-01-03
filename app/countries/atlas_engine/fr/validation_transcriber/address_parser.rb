# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Fr
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        sig { override.returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /#{bldg_num_regex}\s+#{street_regex}/i,
            /#{bldg_num_regex}\s+#{street_regex}(?:,.+)/i,
          ]
        end

        sig { returns(Regexp) }
        def bldg_num_regex
          # examples:
          # 100
          # 100B
          # 100 bis
          @bldg_num_regex ||= T.let(/(?<building_num>\d+\s?([a-z]|bis|ter)?)/i, T.nilable(Regexp))
        end

        sig { returns(Regexp) }
        def street_regex
          @street_regex ||= T.let(/(?<street>.+)/, T.nilable(Regexp))
        end
      end
    end
  end
end
