# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Fr
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrector
            class << self
              extend T::Sig

              sig { params(address: Hash).void }
              def apply(address)
                regex = /^(?<city>.*)\s\b(.+)\b\sArrondissement$/
                m = regex.match(address[:city].first)

                return if m.nil?

                address[:city] = [m["city"]]
              end
            end
          end
        end
      end
    end
  end
end
