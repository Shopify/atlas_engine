# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ComponentsToValidate
          extend T::Sig

          attr_reader :session, :candidate, :street_comparison

          ALL_SUPPORTED_COMPONENTS = [
            :province_code,
            :city,
            :zip,
            :street,
          ].freeze

          sig do
            params(
              session: Session,
              candidate: Candidate,
              street_comparison: T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison),
            ).void
          end
          def initialize(session, candidate, street_comparison)
            @session = session
            @candidate = candidate
            @street_comparison = street_comparison
          end

          sig { returns(T::Array[Symbol]) }
          def run
            supported_components = ALL_SUPPORTED_COMPONENTS.dup - unsupported_components_for_country
            supported_components.delete(:street) if exclude_street_validation?
            supported_components
          end

          private

          sig { returns(T::Boolean) }
          def exclude_street_validation?
            return true unless session.matching_strategy == AddressValidation::MatchingStrategies::EsStreet

            if street_comparison.blank?
              emit_excluded_validation("street", "not_found")
              return true
            end

            if exclusions("street").any? { |exclusion| exclusion.apply?(session, candidate) }
              emit_excluded_validation("street", "excluded")
              return true
            end

            false
          end

          sig { params(component: String).returns(T::Array[T.class_of(Exclusions::ExclusionBase)]) }
          def exclusions(component)
            CountryProfile.for(session.country_code).validation.validation_exclusions(component: component)
          end

          sig { params(component: String, reason: String).void }
          def emit_excluded_validation(component, reason)
            tags = [
              "reason:#{reason}",
              "component:#{component}",
              "country:#{session.country_code}",
            ]
            StatsD.increment("AddressValidation.skip", sample_rate: 1.0, tags: tags)
          end

          sig { returns(T::Array[Symbol]) }
          def unsupported_components_for_country
            unsupported_components = []
            country = Worldwide.region(code: session.address.country_code)
            unsupported_components << :province_code if country.province_optional?
            unsupported_components << :province_code if country.hide_provinces_from_addresses
            unsupported_components << :city unless country.city_required?
            unsupported_components << :zip unless country.zip_required? && !country.zip_autofill_enabled
            unsupported_components.uniq
          end
        end
      end
    end
  end
end
