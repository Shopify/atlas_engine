# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ConcernBuilder
          extend T::Sig

          attr_reader :unmatched_component, :unmatched_field, :matched_components, :address, :suggestion_ids

          class << self
            extend T::Sig

            sig do
              params(
                address: AbstractAddress,
                unmatched_component_keys: T::Array[Symbol],
              ).returns(T::Boolean)
            end
            def should_suggest?(address, unmatched_component_keys)
              return false if too_many_unmatched_components?(address, unmatched_component_keys)

              return false if province_and_city_xor_zip?(unmatched_component_keys) && !valid_zip_for_province?(address)

              true
            end

            sig do
              params(
                address: AbstractAddress,
                unmatched_component_keys: T::Array[Symbol],
              ).returns(T::Boolean)
            end
            def too_many_unmatched_components?(address, unmatched_component_keys)
              unmatched_component_keys.size > unmatched_components_suggestion_threshold(address)
            end

            sig { params(address: AbstractAddress).returns(T::Boolean) }
            def valid_zip_for_province?(address)
              !country_has_zip_codes(address) || province_postal_code_valid?(address)
            end

            private

            sig { params(component_keys: T::Array[Symbol]).returns(T::Boolean) }
            def province_and_city_xor_zip?(component_keys)
              component_keys.include?(:province_code) && component_keys.intersection([:zip, :city]).one?
            end

            sig { params(address: AbstractAddress).returns(T::Boolean) }
            def country_has_zip_codes(address)
              Worldwide.region(code: address.country_code).has_zip?
            end

            def province_postal_code_valid?(address)
              return true if address.province_code.blank?

              country = Worldwide.region(code: address.country_code)
              return true if country.hide_provinces_from_addresses

              province = country.zone(code: address.province_code)
              return true unless province.province?

              province.valid_zip?(address.zip)
            end

            sig { params(address: AbstractAddress).returns(Integer) }
            def unmatched_components_suggestion_threshold(address)
              country_profile = CountryProfile.for(T.must(address.country_code))
              country_profile.validation.unmatched_components_suggestion_threshold
            end
          end

          sig do
            params(
              unmatched_component: Symbol,
              matched_components: T::Array[Symbol],
              address: AbstractAddress,
              suggestion_ids: T::Array[String],
              unmatched_field: T.nilable(Symbol),
            ).void
          end
          def initialize(unmatched_component:, matched_components:, address:, suggestion_ids:, unmatched_field: nil)
            @unmatched_component = unmatched_component
            @unmatched_field = unmatched_field
            @matched_components = matched_components
            @address = address
            @suggestion_ids = suggestion_ids
          end

          sig { returns(AddressValidation::Concern) }
          def build
            case unmatched_component
            when :zip
              build_zip_concern
            when :province_code
              build_province_concern
            else
              build_default_concern
            end
          end

          private

          sig { returns(AddressValidation::Concern) }
          def build_zip_concern
            concern = InvalidZipConcernBuilder.for(address, suggestion_ids)
            return concern if concern

            build_default_concern
          end

          sig { returns(AddressValidation::Concern) }
          def build_province_concern
            if ([:zip, :city] - matched_components).empty?
              UnknownProvinceConcernBuilder.new(address).build(suggestion_ids)
            else
              build_default_concern
            end
          end

          sig { returns(AddressValidation::Concern) }
          def build_default_concern
            UnmatchedFieldConcernBuilder.new(
              unmatched_component,
              matched_components,
              address,
              unmatched_field,
            ).build(suggestion_ids)
          end
        end
      end
    end
  end
end
