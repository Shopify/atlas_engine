# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class AddressComparison
          extend T::Sig
          include Comparable

          attr_reader :street_comparison,
            :city_comparison,
            :zip_comparison,
            :province_code_comparison,
            :building_comparison

          sig do
            params(
              street_comparison: T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison),
              city_comparison: T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison),
              zip_comparison: T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison),
              province_code_comparison: T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison),
              building_comparison: NumberComparison,
            ).void
          end
          def initialize(street_comparison:, city_comparison:, zip_comparison:, province_code_comparison:,
            building_comparison:)
            @street_comparison = street_comparison
            @city_comparison = city_comparison
            @zip_comparison = zip_comparison
            @province_code_comparison = province_code_comparison
            @building_comparison = building_comparison
          end

          sig { params(other: AddressComparison).returns(Integer) }
          def <=>(other)
            # prefer addresses having more matched fields, e.g. matching on street + city + zip is better than
            # just matching on street + zip, or street + province
            matches = comparisons.count(&:match?) <=> other.comparisons.count(&:match?)
            return matches * -1 if matches.nonzero?

            # merge all sequence comparisons together, erasing the individual field boundaries, and prefer
            # the most favorable aggregate comparison
            merged_comparison <=> other.merged_comparison
          end

          sig { returns(String) }
          def inspect
            "<addrcomp street#{comparisons.inspect}/>"
          end

          sig { returns(T::Boolean) }
          def potential_match?
            street_comparison.nil? || T.must(street_comparison).potential_match?
          end

          protected

          sig { returns(T::Array[T.any(AtlasEngine::AddressValidation::Token::Sequence::Comparison, NumberComparison)]) }
          def comparisons
            [
              street_comparison,
              city_comparison,
              zip_comparison,
              province_code_comparison,
              building_comparison,
            ].compact_blank
          end

          sig { returns(T::Array[AtlasEngine::AddressValidation::Token::Sequence::Comparison]) }
          def text_comparisons
            [
              street_comparison,
              city_comparison,
              zip_comparison,
              province_code_comparison,
            ].compact_blank
          end

          sig { returns(AtlasEngine::AddressValidation::Token::Sequence::Comparison) }
          def merged_comparison
            @merged_comparisons ||= text_comparisons.reduce(&:merge)
          end
        end
      end
    end
  end
end
