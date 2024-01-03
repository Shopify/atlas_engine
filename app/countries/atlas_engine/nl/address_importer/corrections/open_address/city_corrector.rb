# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Nl
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                if address[:city] == ["'s-Gravenhage"]
                  address[:city] << "Den Haag"
                end
              end
            end
          end
        end
      end
    end
  end
end
