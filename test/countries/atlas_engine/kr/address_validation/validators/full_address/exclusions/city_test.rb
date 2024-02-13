# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Kr
    module AddressValidation
      module Validators
        module FullAddress
          module Exclusions
            class CityTest < ActiveSupport::TestCase
              include AtlasEngine::AddressValidation::AddressValidationTestHelper

              test "#apply? returns true when candidate city (si only) is present in sesssion address components" do
                address = build_address(
                  address1: "창원시 마산회원구 양덕로190 7층 뷰티제이",
                  city: "",
                  country_code: "KR",
                  zip: "51315",
                  province_code: "KR-48",
                )

                candidate_address = candidate(
                  suburb: "석전동",
                  street: "3·15대로",
                  city: ["창원시"],
                  country_code: "KR",
                  zip: "51315",
                  province_code: "KR-48",
                )

                comparison = mock_address_comparison("창원시", "창원시")

                assert City.apply?(candidate_address, comparison)
              end

              test "#apply? returns true when candidate city (gu only) is present in sesssion address components" do
                address = build_address(
                  address1: "마산회원구 양덕로190 7층 뷰티제이",
                  city: "",
                  country_code: "KR",
                  zip: "51315",
                  province_code: "KR-48",
                )

                candidate_address = candidate(
                  suburb: "석전동",
                  street: "3·15대로",
                  city: ["마산회원구"],
                  country_code: "KR",
                  zip: "51315",
                  province_code: "KR-48",
                )

                comparison = mock_address_comparison("창원시", "마산회원구")

                assert City.apply?(candidate_address, comparison)
              end

              test "#apply? returns true when candidate city (si and gu) are present in session address components" do
                address = build_address(
                  address1: "마산회원구 양덕로190 7층 뷰티제이",
                  city: "창원시",
                  country_code: "KR",
                  zip: "51315",
                  province_code: "KR-48",
                )

                candidate_address = candidate(
                  suburb: "석전동",
                  street: "3·15대로",
                  city: ["창원시 마산회원구"],
                  country_code: "KR",
                  zip: "51315",
                  province_code: "KR-48",
                )

                comparison = mock_address_comparison("창원시", "창원시 마산회원구")

                assert City.apply?(candidate_address, comparison)
              end

              test "#apply? returns false when candidate si is not present in session address components" do
                address = build_address(
                  address1: "양덕로190 7층 뷰티제이",
                  city: "",
                  country_code: "KR",
                  zip: "51315",
                  province_code: "KR-48",
                )

                candidate_address = candidate(
                  suburb: "석전동",
                  street: "3·15대로",
                  city: ["창원시"],
                  country_code: "KR",
                  zip: "51315",
                  province_code: "KR-48",
                )

                comparison = mock_address_comparison("창원시", "창원시 마산회원구")

                assert_not City.apply?(candidate_address, comparison)
              end

              test "#apply? returns false when candidate gu is not present in session address components" do
                address = build_address(
                  address1: "양덕로190 7층 뷰티제이",
                  city: "",
                  country_code: "KR",
                  zip: "51315",
                  province_code: "KR-48",
                )

                candidate_address = candidate(
                  suburb: "석전동",
                  street: "3·15대로",
                  city: ["마산회원구"],
                  country_code: "KR",
                  zip: "51315",
                  province_code: "KR-48",
                )

                comparison = mock_address_comparison("창원시", "창원시 마산회원구")

                assert_not City.apply?(candidate_address, comparison)
              end

              def mock_address_comparison(given_city, candidate_city)
                given_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(given_city)
                candidate_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(candidate_city)
                city_comparison = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
                  left_sequence: given_sequence,
                  right_sequence: candidate_sequence,
                ).compare

                address_comparison = typed_mock(
                  AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison,
                )
                address_comparison.stubs(:city_comparison).returns(city_comparison)
                address_comparison
              end
            end
          end
        end
      end
    end
  end
end
