# typed: true
# frozen_string_literal: true

module AtlasEngine
  module It
    module AddressImporter
      module Corrections
        module OpenAddress
          class SpecialCharacterCorrector
            class << self
              extend T::Sig

              SPECIAL_CHAR_CITY_MAPPING = {
                "ã\u0088" => "è",
                "ã\u0099" => "ù",
                "ã\u0092" => "ò",
                "ã\u0080" => "à",
                "ã\u008C" => "ì",
              }

              SPECIAL_CHAR_STREET_MAPPING = {
                "Ã¹" => "ù",
                "Ã²" => "ò",
                "Ã³" => "ò",
                "Ã¡" => "à",
                "Ã¢" => "â",
                "Ã¼" => "ü",
                "Ã±" => "ñ",
                "Ã«" => "ë",
                "Ã¨" => "è",
                "Ã©" => "e",
                "Ã®" => "i",
                "Ã´" => "o",
                "Ãª" => "ê",
                "Ã»" => "u",
                "Ã¶" => "ö",
                "Ã¬" => "ì",
                "Ã¤" => "a",
                "Ã§" => "c",
                "Ãº" => "u",
              }

              sig { params(address: Hash).void }
              def apply(address)
                fix_city_special_chars(address)
                fix_street_special_chars(address)
              end

              private

              sig { params(address: Hash).void }
              def fix_city_special_chars(address)
                re = special_char_regex(SPECIAL_CHAR_CITY_MAPPING)
                address[:city] = [address[:city].first.gsub(re, SPECIAL_CHAR_CITY_MAPPING)]
              end

              sig { params(address: Hash).void }
              def fix_street_special_chars(address)
                return unless address[:street]

                re = special_char_regex(SPECIAL_CHAR_STREET_MAPPING)
                address[:street] = address[:street].gsub(re, SPECIAL_CHAR_STREET_MAPPING)
                address[:street] = address[:street].tr("Ã", "à")
              end

              sig { params(mapping: Hash).returns(Regexp) }
              def special_char_regex(mapping)
                Regexp.new(mapping.keys.map { |x| Regexp.escape(x) }.join("|"))
              end
            end
          end
        end
      end
    end
  end
end
