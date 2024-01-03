# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Li
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                if address[:city].include?("Gamprin-Bendern")
                  address[:city] += ["Gamprin", "Bendern"]
                end
              end
            end
          end
        end
      end
    end
  end
end
