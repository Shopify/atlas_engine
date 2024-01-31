# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ComparisonHelper
          extend T::Sig

          sig { params(address: AbstractAddress, candidate: Candidate, datastore: DatastoreBase).void }
          def initialize(address:, candidate:, datastore:)
            @address = address
            @datastore = datastore
            @candidate = candidate
          end

          sig { returns(T.nilable(Token::Sequence::Comparison)) }
          def street_comparison
            return @street_comparison if defined?(@street_comparison)

            street_sequences = datastore.fetch_street_sequences
            candidate_sequences = T.must(candidate.component(:street)).sequences

            @street_comparison = street_sequences.map do |street_sequence|
              best_comparison(
                street_sequence,
                candidate_sequences,
                field_policy(:street),
              )
            end.min
          end

          sig { returns(T.nilable(Token::Sequence::Comparison)) }
          def city_comparison
            return @city_comparison if defined?(@city_comparison)

            @city_comparison = best_comparison(
              datastore.fetch_city_sequence,
              T.must(candidate.component(:city)).sequences,
              field_policy(:city),
            )
          end

          sig { returns(T.nilable(Token::Sequence::Comparison)) }
          def province_code_comparison
            return @province_code_comparison if defined?(@province_code_comparison)

            normalized_session_province_code = ValidationTranscriber::ProvinceCodeNormalizer.normalize(
              country_code: address.country_code,
              province_code: address.province_code,
            )
            normalized_candidate_province_code = ValidationTranscriber::ProvinceCodeNormalizer.normalize(
              country_code: T.must(candidate.component(:country_code)).value,
              province_code: T.must(candidate.component(:province_code)).value,
            )

            @province_code_comparison = best_comparison(
              Token::Sequence.from_string(normalized_session_province_code),
              [Token::Sequence.from_string(normalized_candidate_province_code)],
              field_policy(:province_code),
            )
          end

          sig { returns(T.nilable(Token::Sequence::Comparison)) }
          def zip_comparison
            ZipComparison.new(address: address, candidate: candidate, datastore: datastore).compare
          end

          sig { returns(NumberComparison) }
          def building_comparison
            @building_comparison ||= NumberComparison.new(
              numbers: datastore.parsings.potential_building_numbers,
              candidate_ranges: building_ranges_from_candidate(candidate),
            )
          end

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
