# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Bm
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityAliasCorrector
            class << self
              extend T::Sig

              BM_PARISH_AND_CITY_NAMES = {
                "Devonshire" => "Devonshire Parish",
                "Hamilton" => "Hamilton Parish",
                "Paget" => "Paget Parish",
                "Pembroke" => "Pembroke Parish",
                "Sandys" => "Sandys Parish",
                "Smiths" => "Smiths Parish",
                "Southampton" => "Southampton Parish",
                "St. George's" => "St. George's Parish",
                "Town of St. George" => "St. George",
                "Warwick" => "Warwick Parish",
              }.freeze

              sig { params(address: Hash).void }
              def apply(address)
                if BM_PARISH_AND_CITY_NAMES.key?(address[:city][0])
                  address[:city] << BM_PARISH_AND_CITY_NAMES[address[:city][0]]
                end
              end
            end
          end
        end
      end
    end
  end
end
