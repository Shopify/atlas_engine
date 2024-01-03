# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Lu
    module AddressImporter
      module Corrections
        module OpenAddress
          class LocaleCorrector
            class << self
              extend T::Sig

              FRENCH_STREET_PREFIXES = [
                "Allée",
                "Avenue",
                "Boulevard",
                "Centre",
                "Ceinture",
                "Chemin",
                "Cité",
                "Domaine",
                "Impasse",
                "Maison",
                "Montée",
                "Parc",
                "Passage",
                "Place",
                "Plateau",
                "Porte",
                "Rond-Point",
                "Rond Point",
                "Route",
                "Rue",
                "Sentier",
                "Zone",
              ]

              sig { params(address: Hash).void }
              def apply(address)
                street = address[:street]

                address[:locale] = if FRENCH_STREET_PREFIXES.any? { |prefix| street.start_with?(prefix) }
                  "fr"
                else
                  "lb"
                end
              end
            end
          end
        end
      end
    end
  end
end
