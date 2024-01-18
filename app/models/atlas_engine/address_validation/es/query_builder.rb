# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      class QueryBuilder
        extend T::Helpers
        extend T::Sig

        abstract!
        class << self
          extend T::Sig

          sig { params(address: AbstractAddress, locale: T.nilable(String)).returns(QueryBuilder) }
          def for(address, locale = nil)
            profile = CountryProfile.for(T.must(address.country_code), locale)
            profile.attributes.dig("validation", "query_builder").constantize.new(address, locale)
          end
        end

        sig { params(address: AbstractAddress, locale: T.nilable(String)).void }
        def initialize(address, locale = nil)
          @address = address
          @profile = CountryProfile.for(T.must(address.country_code), locale)
          @parsings = ValidationTranscriber::AddressParsings.new(address_input: address, locale: locale)
        end

        sig { abstract.returns(T::Hash[String, T.untyped]) }
        def full_address_query; end

        private

        sig { returns(AbstractAddress) }
        attr_reader :address

        sig { returns(CountryProfile) }
        attr_reader :profile

        sig { returns(Hash) }
        def building_number_clause
          potential_building_numbers = @parsings.potential_building_numbers.filter_map do |n|
            AddressNumber.new(value: n).to_i
          end.uniq

          building_number_queries = [empty_approx_building_clause]
          building_number_queries.unshift(
            *T.unsafe(potential_building_numbers.map do |value|
              approx_building_clause(value)
            end),
          ) if potential_building_numbers.any?

          {
            "dis_max" => {
              "queries" => building_number_queries,
            },
          }
        end

        sig { params(value: Integer).returns(Hash) }
        def approx_building_clause(value)
          {
            "term" => {
              "approx_building_ranges" => {
                "value" => value,
              },
            },
          }
        end

        sig { returns(Hash) }
        def empty_approx_building_clause
          {
            "bool" => {
              "must_not" => {
                "exists" => {
                  "field" => "approx_building_ranges",
                },
              },
            },
          }
        end

        sig { returns(Hash) }
        def street_clause
          {
            "dis_max" => {
              "queries" => street_query_values.map do |value|
                {
                  "match" => {
                    "street" => { "query" => value, "fuzziness" => "auto" },
                  },
                }
              end.union(
                stripped_street_query_values.map do |value|
                  {
                    "match" => {
                      "street_stripped" => { "query" => value, "fuzziness" => "auto" },
                    },
                  }
                end,
              ),
            },
          }
        end

        sig { returns(T::Array[String]) }
        def street_query_values
          street_names.presence || [address.address1.to_s, address.address2.to_s].compact_blank.uniq
        end

        sig { returns(T::Array[String]) }
        def street_names
          streets = @parsings.potential_streets
          (streets + streets.map { |street| Street.new(street: street).with_stripped_name }).uniq
        end

        sig { returns(T::Array[String]) }
        def stripped_street_query_values
          @parsings.potential_streets.map { |street| Street.new(street: street).with_stripped_name }.uniq
        end

        sig { returns(T.nilable(Hash)) }
        def city_clause
          {
            "nested" => {
              "path" => "city_aliases",
              "query" => {
                "match" => {
                  "city_aliases.alias" => { "query" => address.city.to_s, "fuzziness" => "auto" },
                },
              },
            },
          }
        end

        sig { returns(Hash) }
        def zip_clause
          normalized_zip = ValidationTranscriber::ZipNormalizer.normalize(
            country_code: address.country_code, zip: address.zip,
          )
          {
            "match" => {
              "zip" => { "query" => normalized_zip, "fuzziness" => "auto" },
            },
          }
        end

        sig { returns(T.nilable(Hash)) }
        def province_clause
          {
            "term" => {
              "province_code" => { "value" => address.province_code.to_s.downcase },
            },
          } if profile.attributes.dig("validation", "has_provinces") && address.province_code.present?
        end
      end
    end
  end
end
