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

          sig { params(address: AbstractAddress, candidate: Candidate, datastore: DatastoreBase).void }
          def initialize(address:, candidate:, datastore:)
            @street_comparison = ComparisonHelper.street_comparison(
              datastore: datastore,
              candidate: candidate,
            )
            @city_comparison = ComparisonHelper.city_comparison(
              datastore: datastore,
              candidate: candidate,
            )
            @zip_comparison = ComparisonHelper.zip_comparison(
              address: address,
              candidate: candidate,
            )
            @province_code_comparison = ComparisonHelper.province_code_comparison(
              address: address,
              candidate: candidate,
            )
            @building_comparison = ComparisonHelper.building_comparison(
              datastore: datastore,
              candidate: candidate,
            )
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

          sig do
            returns(T::Array[T.any(AtlasEngine::AddressValidation::Token::Sequence::Comparison, NumberComparison)])
          end
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
