# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class MatchingStrategies < T::Enum
      include Strategies

      enums do
        Es = new("es")
        EsStreet = new("es_street")
        Local = new("local")
        EsPredicates = new("es_predicates")
      end
    end
  end
end
