# typed: true
# frozen_string_literal: true

module AtlasEngine
  module It
    module AddressImporter
      module Corrections
        module OpenAddress
          class ProvinceCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                if address[:region2] == "BOLZANO/BOZEN"
                  address[:province_code] = "BZ"
                elsif address[:region2] == "FORLI'-CESENA"
                  address[:province_code] = "FC"
                elsif address[:region2] == "REGGIO DI CALABRIA"
                  address[:province_code] = "RC"
                end
              end
            end
          end
        end
      end
    end
  end
end
