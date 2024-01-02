# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Au
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        # Temporary till we fix constants loading for AddressParsers
        # Source: https://meteor.aihw.gov.au/content/429004
        UNIT_TYPE_KEYWORDS = T.let(
          Set.new([
            "ant",
            "apt",
            "atm",
            "bbq",
            "btsd",
            "bldg",
            "bngw",
            "cage",
            "carp",
            "cars",
            "club",
            "cool",
            "ctge",
            "dupl",
            "fcty",
            "flat",
            "grge",
            "hall",
            "hse",
            "ksk",
            "lse",
            "lbby",
            "loft",
            "lot",
            "msnt",
            "mbth",
            "offc",
            "resv",
            "room",
            "shed",
            "shop",
            "shrm",
            "sign",
            "site",
            "stll",
            "stor",
            "str",
            "stu",
            "subs",
            "se",
            "tncy",
            "twr",
            "tnhs",
            "unit",
            "vlt",
            "vlla",
            "ward",
            "whse",
            "wksh",
          ]),
          T::Set[String],
        )

        sig { override.returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /(#{unit_regex})?#{bldg_num_regex}\s+#{street_regex}/i,
          ]
        end

        private

        sig { returns(Regexp) }
        def unit_regex
          # examples
          # 10
          # 10/
          # flat 10
          # flat 10,
          # flat 10/
          # 10A
          # A10
          @unit_regex ||= T.let(
            %r{
                (?<unit_type>(#{unit_type_list}))?\s*
                (?<unit_num>\d+[a-z]?|[a-z]?\d+)(\s|\/|,)+
              }ix,
            T.nilable(Regexp),
          )
        end

        sig { returns(Regexp) }
        def bldg_num_regex
          # examples:
          # 100
          # 100B
          # 100-102
          @bldg_num_regex ||= T.let(/(?<building_num>\d+(\-\d+|[a-z]?))/i, T.nilable(Regexp))
        end

        sig { returns(Regexp) }
        def street_regex
          @street_regex ||= T.let(/(?<street>.+)/, T.nilable(Regexp))
        end

        sig { override.params(token: T.nilable(String)).returns(T::Boolean) }
        def secondary_unit_designator?(token)
          return false if token.blank?

          UNIT_TYPE_KEYWORDS.include?(token)
        end

        sig { returns(String) }
        def unit_type_list
          UNIT_TYPE_KEYWORDS.join("|")
        end
      end
    end
  end
end
