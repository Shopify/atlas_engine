# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class InvalidZipConcernBuilder
          class << self
            extend T::Sig

            sig do
              params(
                country: Worldwide::Region,
                address: AbstractAddress,
                suggestion_ids: T::Array[String],
              ).returns(T.nilable(AddressValidation::Concern))
            end
            def for(country, address, suggestion_ids)
              province = country.zone(code: address.province_code.presence || "")
              return unless country.has_zip?

              if country_expects_zone_in_address?(country) && province.province?
                InvalidZipForProvinceConcern.new(
                  country,
                  address,
                  suggestion_ids,
                ) unless province.valid_zip?(address.zip)
              else
                InvalidZipForCountryConcern.new(country, address, suggestion_ids) unless country.valid_zip?(address.zip)
              end
            end

            private

            sig { params(country: Worldwide::Region).returns(T::Boolean) }
            def country_expects_zone_in_address?(country)
              country.zones&.any?(&:province?) && !country.hide_provinces_from_addresses
            end
          end
        end
      end
    end
  end
end
