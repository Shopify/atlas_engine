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

          delegate :parsings, to: :datastore

          sig { params(address: AbstractAddress, candidate: Candidate, datastore: DatastoreBase).void }
          def initialize(address:, candidate:, datastore:)
            @address = address
            @candidate = candidate
            @datastore = datastore
            @comparators_hash = {}
          end

          sig { params(other: AddressComparison).returns(Integer) }
          def <=>(other)
            # prefer addresses having more matched fields, e.g. matching on street + city + zip is better than
            # just matching on street + zip, or street + province
            matches = comparators.count(&:match?) <=> other.comparators.count(&:match?)
            return matches * -1 if matches.nonzero?

            # merge all sequence comparisons together, erasing the individual field boundaries, and prefer
            # the most favorable aggregate comparison
            merged_comparison <=> other.merged_comparison
          end

          sig { returns(String) }
          def inspect
            "<addrcomp street#{comparators.inspect}/>"
          end

          sig { returns(T::Boolean) }
          def potential_match?
            street_comparison.sequence_comparison.nil? || T.must(street_comparison.sequence_comparison).potential_match?
          end

          sig { returns(ZipComparison) }
          def zip_comparison
            T.cast(self.for(:zip), ZipComparison)
          end

          sig { returns(StreetComparison) }
          def street_comparison
            T.cast(self.for(:street), StreetComparison)
          end

          sig { returns(CityComparison) }
          def city_comparison
            T.cast(self.for(:city), CityComparison)
          end

          sig { returns(ProvinceCodeComparison) }
          def province_code_comparison
            T.cast(self.for(:province_code), ProvinceCodeComparison)
          end

          sig { returns(BuildingComparison) }
          def building_comparison
            T.cast(self.for(:building), BuildingComparison)
          end

          sig { params(component: Symbol).returns(FieldComparisonBase) }
          def for(component)
            @comparators_hash[component] ||= begin
              klass = datastore.country_profile.validation.component_comparison(component)
              klass.new(
                address: address,
                candidate: candidate,
                datastore: datastore,
                component: component,
              )
            end
          end

          sig { returns(T::Array[Symbol]) }
          def components
            comparators.map(&:component)
          end

          sig { returns(T::Array[Symbol]) }
          def relevant_components
            comparators.select(&:relevant?).map(&:component)
          end

          sig do
            returns(T::Array[FieldComparisonBase])
          end
          def comparators
            datastore.country_profile.validation.address_comparison.keys.map do |component|
              self.for(component.to_sym)
            end
          end

          sig { returns(T::Array[AtlasEngine::AddressValidation::Token::Sequence::Comparison]) }
          def text_comparisons
            comparators.filter_map do |comparator|
              comparison = comparator.sequence_comparison
              comparison if comparison.class == AtlasEngine::AddressValidation::Token::Sequence::Comparison
            end.compact_blank
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
