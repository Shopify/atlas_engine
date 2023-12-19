# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      class DefaultQueryBuilder < QueryBuilder
        extend T::Sig

        sig { params(address: AbstractAddress).void }
        def initialize(address)
          super(address)
        end

        sig { override.returns(T::Hash[String, T.untyped]) }
        def full_address_query
          clauses = [
            building_number_clause,
            street_clause,
            city_clause,
            zip_clause,
            province_clause,
          ].compact
          {
            "query" => {
              "bool" =>
                {
                  "should" => clauses,
                  "minimum_should_match" => clauses.count - 2,
                },
            },
          }
        end
      end
    end
  end
end