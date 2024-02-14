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

          sig do
            params(
              address: AbstractAddress,
              parsings: AtlasEngine::ValidationTranscriber::AddressParsings,
              locale: T.nilable(String),
            ).returns(QueryBuilder)
          end
          def for(address, parsings, locale = nil)
            profile = CountryProfile.for(T.must(address.country_code), locale)
            profile.attributes.dig("validation", "query_builder").constantize.new(address, parsings, profile)
          end
        end

        sig do
          params(
            address: AbstractAddress,
            parsings: AtlasEngine::ValidationTranscriber::AddressParsings,
            profile: CountryProfile,
          ).void
        end
        def initialize(address, parsings, profile)
          @address = address
          @profile = profile
          @parsings = parsings
        end

        sig { abstract.returns(T::Hash[String, T.untyped]) }
        def full_address_query; end

        private

        sig { returns(AbstractAddress) }
        attr_reader :address

        sig { returns(CountryProfile) }
        attr_reader :profile

        sig { returns(T.nilable(Hash)) }
        def building_number_clause
          building_number_clause = approx_building_clauses

          return if building_number_clause.nil?

          {
            "dis_max" => {
              "queries" => building_number_clause,
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

        sig { returns(T.nilable(Array)) }
        def approx_building_clauses
          potential_building_numbers = @parsings.potential_building_numbers.filter_map do |n|
            AddressNumber.new(value: n).to_i
          end.uniq

          if potential_building_numbers.any?
            potential_building_numbers.map do |value|
              approx_building_clause(value)
            end
          end
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
              "queries" => build_street_queries,
            },
          }
        end

        sig { returns(Array) }
        def build_street_queries
          street_query_values.map do |value|
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
          )
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
              "zip" => {
                "query" => normalized_zip,
                "fuzziness" => "auto",
                "prefix_length" => profile.validation.zip_prefix_length,
              },
            },
          }
        end

        sig { returns(T.nilable(Hash)) }
        def province_clause
          {
            "match" => {
              "province_code" => { "query" => address.province_code.to_s.downcase },
            },
          } if profile.attributes.dig("validation", "has_provinces") && address.province_code.present?
        end
      end
    end
  end
end
