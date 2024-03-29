# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module Pl
    module AddressValidation
      module Exclusions
        class RuralAddressTest < ActiveSupport::TestCase
          include AtlasEngine::AddressValidation::AddressValidationTestHelper
          include AtlasEngine::AddressValidation::TokenHelper

          test "#apply? returns true when candidate has matching street and city names and city comparison is poor" do
            rural_candidate_address = build_address(
              address1: "Kotowa Wola",
              city: "Kotowa Wola",
              country_code: "PL",
              zip: "37-415",
            )
            candidate = candidate(rural_candidate_address)
            comparison = mock_address_comparison("Zaleszany", "Kotowa Wola")
            assert RuralAddress.apply?(candidate, comparison)
          end

          test "#apply? returns false when candidate has matching street and city names and city comparison is close" do
            rural_candidate_address = build_address(
              address1: "Kotowa Wola",
              city: "Kotowa Wola",
              country_code: "PL",
              zip: "37-415",
            )
            candidate = candidate(rural_candidate_address)
            comparison = mock_address_comparison("Kotowa Kola", "Kotowa Wola")
            assert_not RuralAddress.apply?(candidate, comparison)
          end

          test "#apply? returns false when candidate has differing street and city values (not rural)" do
            candidate_address = build_address(
              address1: "Kotowa Wola",
              city: "Trzebnica",
              country_code: "PL",
              zip: "37-415",
            )
            candidate = candidate(candidate_address)
            comparison = mock_address_comparison("Zaleszany", "Trzebnica")
            assert_not RuralAddress.apply?(candidate, comparison)
          end

          private

          def mock_address_comparison(given_city, candidate_city)
            given_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(given_city)
            candidate_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(candidate_city)
            city_comparison_result = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: given_sequence,
              right_sequence: candidate_sequence,
            ).compare

            city_comparison = typed_mock(AtlasEngine::AddressValidation::Validators::FullAddress::CityComparison)
            city_comparison.stubs(:sequence_comparison).returns(city_comparison_result)

            address_comparison = typed_mock(AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison)
            address_comparison.stubs(:city_comparison).returns(city_comparison)
            address_comparison
          end
        end
      end
    end
  end
end
