# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class AddressComparison
          extend T::Sig
          include Comparable

          attr_reader :address, :candidate, :datastore

          sig { params(address: AbstractAddress, candidate: Candidate, datastore: DatastoreBase).void }
          def initialize(address:, candidate:, datastore:)
            @address = address
            @candidate = candidate
            @datastore = datastore
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
            street_comparison.sequence_comparison.nil? || T.must(street_comparison.sequence_comparison).potential_match?
          end

          sig { returns(ZipComparison) }
          def zip_comparison
            @zip_comparison ||= field_comparison(field: :zip)
          end

          sig { returns(StreetComparison) }
          def street_comparison
            @street_comparison ||= field_comparison(field: :street)
          end

          sig { returns(CityComparison) }
          def city_comparison
            @city_comparison ||= field_comparison(field: :city)
          end

          sig { returns(ProvinceCodeComparison) }
          def province_code_comparison
            @province_code_comparison ||= field_comparison(field: :province_code)
          end

          sig { returns(BuildingComparison) }
          def building_comparison
            @building_comparison ||= field_comparison(field: :building)
          end

          sig do
            returns(T::Array[FieldComparisonBase])
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

          protected

          sig { returns(T::Array[AtlasEngine::AddressValidation::Token::Sequence::Comparison]) }
          def text_comparisons
            [
              street_comparison.sequence_comparison,
              city_comparison.sequence_comparison,
              zip_comparison.sequence_comparison,
              province_code_comparison.sequence_comparison,
            ].compact_blank
          end

          sig { returns(AtlasEngine::AddressValidation::Token::Sequence::Comparison) }
          def merged_comparison
            @merged_comparisons ||= text_comparisons.reduce(&:merge)
          end

          sig { params(field: Symbol).returns(FieldComparisonBase) }
          def field_comparison(field:)
            klass = CountryProfile.for(address.country_code).validation.address_comparison(field: field)
            klass.new(address: address, candidate: candidate, datastore: datastore)
          end
        end
      end
    end
  end
end
