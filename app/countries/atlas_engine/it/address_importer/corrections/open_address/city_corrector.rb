# typed: true
# frozen_string_literal: true

module AtlasEngine
  module It
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                if address[:city] == ["Sissa"]
                  address[:city] = ["Sissa Trecasali"]
                elsif address[:city] == ["Reggio Nell'emilia"]
                  address[:city] << "Reggio Emilia"
                end
              end
            end
          end
        end
      end
    end
  end
end
