# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class FieldComparisonBase
          extend T::Sig
          extend T::Helpers

          abstract!

          sig { params(address: AbstractAddress, candidate: Candidate, datastore: DatastoreBase).void }
          def initialize(address:, candidate:, datastore:)
            @address = address
            @datastore = datastore
            @candidate = candidate
          end

          sig { abstract.returns(T.nilable(Token::Sequence::Comparison)) }
          def compare; end

          private

          sig { returns(AbstractAddress) }
          attr_reader :address

          sig { returns(DatastoreBase) }
          attr_reader :datastore

          sig { returns(Candidate) }
          attr_reader :candidate

          sig do
            params(
              sequence: Token::Sequence,
              component_sequences: T::Array[Token::Sequence],
              comparison_policy: Token::Sequence::ComparisonPolicy,
            ).returns(T.nilable(Token::Sequence::Comparison))
          end
          def best_comparison(
            sequence,
            component_sequences,
            comparison_policy = Token::Sequence::ComparisonPolicy::DEFAULT_POLICY
          )
            component_sequences.map do |component_sequence|
              Token::Sequence::Comparator.new(
                left_sequence: sequence,
                right_sequence: component_sequence,
                comparison_policy:,
              ).compare
            end.min_by.with_index do |comparison, index|
              # ruby's `min` and `sort` methods are not stable
              # so we need to prefer the leftmost comparison when two comparisons are equivalent
              [comparison, index]
            end
          end

          sig { params(field: Symbol).returns(Token::Sequence::ComparisonPolicy) }
          def field_policy(field)
            datastore.country_profile.validation.comparison_policy(field)
          end

          sig { params(candidate: Candidate).returns(T::Array[AddressNumberRange]) }
          def building_ranges_from_candidate(candidate)
            building_and_unit_ranges = candidate.component(:building_and_unit_ranges)&.value
            return [] if building_and_unit_ranges.blank?

            building_ranges = JSON.parse(building_and_unit_ranges).keys
            building_ranges.map { |building_range| AddressNumberRange.new(range_string: building_range) }
          end
        end
      end
    end
  end
end
