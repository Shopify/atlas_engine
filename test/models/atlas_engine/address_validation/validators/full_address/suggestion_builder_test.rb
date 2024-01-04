# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class SuggestionBuilderTest < ActiveSupport::TestCase
          def setup
            @address = {
              address1: "123 First Avenue",
              address2: nil,
              city: "San Francisco",
              province_code: "CA",
              country_code: "US",
              zip: "94102",
              phone: nil,
            }
          end

          test ".from_comparisons has suggestions for multiple fields" do
            right_street = "Main Street"
            wrong_street = "Man Street"

            right_zip = "94102"
            wrong_zip = "12345"

            @address[:address1] = "123 #{wrong_street}"
            @address[:zip] = wrong_zip

            candidate = AddressValidation::Candidate.new(id: "1", source: {
              street: right_street,
              zip: right_zip,
            })

            street_comparison = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: AtlasEngine::AddressValidation::Token::Sequence.from_string(wrong_street),
              right_sequence: T.must(T.must(candidate.component(:street)).sequences.first),
            ).compare

            zip_comparison = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: AtlasEngine::AddressValidation::Token::Sequence.from_string(wrong_zip),
              right_sequence: T.must(T.must(candidate.component(:zip)).sequences.first),
            ).compare

            comparisons = { street: street_comparison, zip: zip_comparison }

            suggestion = SuggestionBuilder.from_comparisons(@address, comparisons, candidate, { street: :address1 })

            expected_suggestion = {
              address1: "123 #{right_street}",
              address2: nil,
              city: nil,
              province_code: nil,
              province: nil,
              zip: right_zip,
              country_code: nil,
            }

            assert_equal expected_suggestion, suggestion.attributes.except(:id)
          end

          test ".from_comparisons returns the expected province details" do
            right_province_code = "MA"
            wrong_province_code = "NY"

            @address[:province_code] = wrong_province_code

            candidate = AddressValidation::Candidate.new(id: "1", source: {
              province_code: right_province_code,
            })

            comparison = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: AtlasEngine::AddressValidation::Token::Sequence.from_string(wrong_province_code),
              right_sequence: T.must(T.must(candidate.component(:province_code)).sequences.first),
            ).compare

            comparisons = { province_code: comparison }

            suggestion = SuggestionBuilder.from_comparisons(@address, comparisons, candidate)

            expected_suggestion = {
              address1: nil,
              address2: nil,
              city: nil,
              province_code: "MA",
              province: "Massachusetts",
              zip: nil,
              country_code: nil,
            }

            assert_equal expected_suggestion, suggestion.attributes.except(:id)
          end

          test ".from_comparisons returns the expected street details when the unmatched street field is address1" do
            right_street = "Main Street"
            wrong_street = "Man Street"

            @address[:address1] = "123 #{wrong_street}"

            candidate = AddressValidation::Candidate.new(id: "1", source: { street: right_street })

            comparison = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: AtlasEngine::AddressValidation::Token::Sequence.from_string(wrong_street),
              right_sequence: T.must(T.must(candidate.component(:street)).sequences.first),
            ).compare

            comparisons = { street: comparison }

            suggestion = SuggestionBuilder.from_comparisons(@address, comparisons, candidate, { street: :address1 })

            expected_suggestion = {
              address1: "123 #{right_street}",
              address2: nil,
              city: nil,
              province_code: nil,
              province: nil,
              zip: nil,
              country_code: nil,
            }

            assert_equal expected_suggestion, suggestion.attributes.except(:id)
          end

          test ".from_comparisons returns the expected street details when the unmatched street field is address2" do
            right_street = "Main Street"
            wrong_street = "Man Street"

            @address[:address2] = "Apt 7, #{wrong_street}"

            candidate = AddressValidation::Candidate.new(id: "1", source: {
              street: right_street,
            })

            comparison = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: AtlasEngine::AddressValidation::Token::Sequence.from_string(wrong_street),
              right_sequence: T.must(T.must(candidate.component(:street)).sequences.first),
            ).compare

            comparisons = { street: comparison }

            suggestion = SuggestionBuilder.from_comparisons(@address, comparisons, candidate, { street: :address2 })

            expected_suggestion = {
              address1: nil,
              address2: "Apt 7, #{right_street}",
              city: nil,
              province_code: nil,
              province: nil,
              zip: nil,
              country_code: nil,
            }

            assert_equal expected_suggestion, suggestion.attributes.except(:id)
          end

          test ".from_comparisons returns the expected street details when the unmatched street field does not exist" do
            right_street = "Main Street"
            wrong_street = "Man Street"

            candidate = AddressValidation::Candidate.new(id: "1", source: {
              street: right_street,
              city: ["San Francisco"],
              province_code: "CA",
              country_code: "US",
              zip: "94102",
              phone: nil,
            })

            comparison = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: AtlasEngine::AddressValidation::Token::Sequence.from_string(wrong_street),
              right_sequence: T.must(T.must(candidate.component(:street)).sequences.first),
            ).compare

            comparisons = { street: comparison }

            suggestion = SuggestionBuilder.from_comparisons(@address, comparisons, candidate, {})

            expected_suggestion = {
              address1: nil,
              address2: nil,
              city: nil,
              zip: nil,
              province_code: nil,
              province: nil,
              country_code: nil,
            }

            assert_equal expected_suggestion, suggestion.attributes.except(:id)
          end

          test ".from_comparisons chooses the preferred city alias when city has no matching tokens" do
            wrong_city = "Mt Juliet"
            @address[:city] = wrong_city

            candidate = AddressValidation::Candidate.new(id: "1", source: {
              city: ["Old Hickory", "Lakewood"],
            })

            comparison = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: AtlasEngine::AddressValidation::Token::Sequence.from_string(wrong_city),
              right_sequence: AtlasEngine::AddressValidation::Token::Sequence.from_string("Lakewood"),
            ).compare

            comparisons = { city: comparison }

            suggestion = SuggestionBuilder.from_comparisons(@address, comparisons, candidate)

            expected_suggestion = {
              address1: nil,
              address2: nil,
              city: "Old Hickory",
              province_code: nil,
              province: nil,
              zip: nil,
              country_code: nil,
            }

            assert_equal expected_suggestion, suggestion.attributes.except(:id)
          end

          test ".from_comparisons chooses the preferred city alias when matching city has edit distance > 2" do
            wrong_city = "Lincolnwood"
            @address[:city] = wrong_city

            candidate = AddressValidation::Candidate.new(id: "1", source: {
              city: ["Old Hickory", "Lakewood"],
            })

            comparison = AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: AtlasEngine::AddressValidation::Token::Sequence.from_string(wrong_city),
              right_sequence: AtlasEngine::AddressValidation::Token::Sequence.from_string("Lakewood"),
            ).compare

            comparisons = { city: comparison }

            suggestion = SuggestionBuilder.from_comparisons(@address, comparisons, candidate)

            expected_suggestion = {
              address1: nil,
              address2: nil,
              city: "Old Hickory",
              province_code: nil,
              province: nil,
              zip: nil,
              country_code: nil,
            }

            assert_equal expected_suggestion, suggestion.attributes.except(:id)
          end
        end
      end
    end
  end
end
