# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Ch
    module AddressImporter
      module Corrections
        module OpenAddress
          class LocaleCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                province_code = address[:province_code]
                zip = address[:zip].to_i

                if [
                  "ZH",
                  "BE",
                  "LU",
                  "TG",
                  "SZ",
                  "AG",
                  "SO",
                  "AI",
                  "AR",
                  "GL",
                  "SG",
                  "SH",
                  "UR",
                  "ZG",
                  "OW",
                  "NW",
                  "BL",
                  "BS",
                ].to_set.include?(province_code)
                  address[:locale] = "de"
                elsif ["GE", "VD", "NE", "JU"].to_set.include?(province_code)
                  address[:locale] = "fr"
                elsif province_code == "TI"
                  address[:locale] = "it"
                elsif province_code == "FR"
                  address[:locale] = if zip < 1700 || zip >= 1720 && zip < 1734 || zip >= 1740 && zip < 1791
                    "fr"
                  else
                    "de"
                  end
                elsif province_code == "VS"
                  address[:locale] = if zip < 3900 || zip >= 3960 && zip < 3970 || zip >= 3971 && zip < 3982
                    "fr"
                  else
                    "de"
                  end
                elsif province_code == "GR"
                  if zip < 7000 || zip >= 7013 && zip < 7015 || zip >= 7016 && zip < 7023 ||
                      zip >= 7031 && zip < 7050 || zip >= 7077 && zip < 7104 || zip >= 7112 && zip < 7122 ||
                      zip >= 7126 && zip < 7130 || zip >= 7137 && zip < 7147 || zip >= 7151 && zip < 7202 ||
                      zip >= 7500 && zip < 7562 || zip >= 7602
                    address[:locale] = "it"
                  elsif (zip == 7130 || zip >= 7402 && zip < 7404 || zip == 7477) && address[:street].start_with?("Via")
                    address[:locale] = "it"
                  else
                    address[:locale] = "de"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
