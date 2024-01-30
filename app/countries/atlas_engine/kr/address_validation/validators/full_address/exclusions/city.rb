# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Kr
    module AddressValidation
      module Validators
        module FullAddress
          module Exclusions
            class City <
              AtlasEngine::AddressValidation::Validators::FullAddress::Exclusions::ExclusionBase
              extend T::Sig
              class << self
                COMPONENT_IDENTIFIER = {
                  si: "시",
                  gu: "구",
                }.freeze

                sig do
                  override.params(
                    session: AtlasEngine::AddressValidation::Session,
                    candidate: AtlasEngine::AddressValidation::Candidate,
                    address_comparison: AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison,
                  )
                    .returns(T::Boolean)
                end
                def apply?(session, candidate, address_comparison)
                  candidate_si = extract_component_from_city(candidate, :si)
                  candidate_gu = extract_component_from_city(candidate, :gu)

                  (candidate_si.present? && contains_component?(:si, candidate_si, session)) ||
                    (candidate_gu.present? && contains_component?(:gu, candidate_gu, session))
                end

                private

                sig do
                  params(
                    candidate: AtlasEngine::AddressValidation::Candidate,
                    component: Symbol,
                  ).returns(T.nilable(String))
                end
                def extract_component_from_city(candidate, component)
                  city = candidate.component(:city)&.value&.first

                  city_parts = city.split(" ")
                  city_parts.find do |part|
                    part.end_with?(COMPONENT_IDENTIFIER[component])
                  end
                end

                sig do
                  params(
                    type: Symbol,
                    value: String,
                    session: AtlasEngine::AddressValidation::Session,
                  ).returns(T::Boolean)
                end
                def contains_component?(type, value, session)
                  session.parsings.parsings.pluck(type)&.include?(value) || session.city&.include?(value)
                end
              end
            end
          end
        end
      end
    end
  end
end
