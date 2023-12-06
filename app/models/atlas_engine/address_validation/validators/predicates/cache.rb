# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class Cache
          extend T::Sig

          sig { params(address: Address).void }
          def initialize(address)
            @address = address
            @empty_region = Worldwide::Region.new(iso_code: "ZZ")
          end

          sig { returns(Worldwide::Region) }
          def country
            if @address.country_code.present?
              @country ||= Worldwide.region(code: @address.country_code)
            else
              @empty_region
            end
          end

          sig { returns(Worldwide::Region) }
          def province
            if @address.province_code.present?
              @province ||= country.zone(code: @address.province_code)
            else
              @empty_region
            end
          end
        end
      end
    end
  end
end
