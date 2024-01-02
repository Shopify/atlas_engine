# typed: true
# frozen_string_literal: true

module AtlasEngine
  module At
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                address[:city] = ["Wien"] if address[:zip].starts_with?("1")
              end
            end
          end
        end
      end
    end
  end
end
