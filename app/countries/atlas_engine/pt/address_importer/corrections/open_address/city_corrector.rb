# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Pt
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                city_aliases = [
                  { city_name: "Vila Nova De Gaia", alias: "Gaia" },
                  { city_name: "Portela Lrs", alias: "Portela" },
                  { city_name: "Vila Chã Vcd", alias: "Vila Chã" },
                  { city_name: "Alverca Do Ribatejo", alias: "Alverca" },
                ]

                city_aliases.each do |city_alias|
                  address[:city] << city_alias[:alias] if address[:city].include?(city_alias[:city_name])
                end
              end
            end
          end
        end
      end
    end
  end
end
