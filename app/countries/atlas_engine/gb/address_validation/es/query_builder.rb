# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Gb
    module AddressValidation
      module Es
        class QueryBuilder < AtlasEngine::AddressValidation::Es::QueryBuilder
          extend T::Sig

          sig { params(address: AtlasEngine::AddressValidation::AbstractAddress, locale: T.nilable(String)).void }
          def initialize(address, locale = nil)
            super(address, locale)

            @parsings = T.let(
              AtlasEngine::Gb::ValidationTranscriber::FullAddressParser
                .new(address: address).parse,
              T::Array[ValidationTranscriber::ParsedAddress],
            )
          end

          sig { override.returns(T::Hash[String, T.untyped]) }
          def full_address_query
            {
              "query" => {
                "dis_max" => {
                  "queries" => @parsings.map { |parsing| query_for_parsing(parsing) },
                },
              },
            }
          end

          private

          sig { params(parsing: ValidationTranscriber::ParsedAddress).returns(T.nilable(T::Hash[String, T.untyped])) }
          def locality_clause(parsing)
            return if parsing.double_dependent_locality.blank? &&
              parsing.dependent_locality.blank? &&
              parsing.post_town.blank?

            {
              "bool" => {
                "should" => [
                  {
                    "match" => {
                      "region4" => { "query" => parsing.double_dependent_locality || "", "fuzziness" => "auto" },
                    },
                  },
                  {
                    "match" => {
                      "region3" => { "query" => parsing.dependent_locality || "", "fuzziness" => "auto" },
                    },
                  },
                  {
                    "nested" => {
                      "path" => "city_aliases",
                      "query" => {
                        "match" => {
                          "city_aliases.alias" => { "query" => parsing.post_town || "", "fuzziness" => "auto" },
                        },
                      },
                    },
                  },
                ],
              },
            }
          end

          sig { params(parsing: ValidationTranscriber::ParsedAddress).returns(T.nilable(T::Hash[String, T.untyped])) }
          def query_for_parsing(parsing)
            {
              "bool" => {
                "should" => [
                  thoroughfare_clause(parsing),
                  locality_clause(parsing),
                  zip_clause,
                ].compact,
              },
            }
          end

          sig { params(parsing: ValidationTranscriber::ParsedAddress).returns(T.nilable(T::Hash[String, T.untyped])) }
          def thoroughfare_clause(parsing)
            street_name = [parsing.dependent_street, parsing.street].compact.join(", ")

            return if street_name.blank?

            {
              "match" => {
                "street" => { "query" => street_name, "fuzziness" => "auto" },
              },
            }
          end
        end
      end
    end
  end
end
