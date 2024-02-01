# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Types
    class MatchingStrategyType < BaseEnum
      value :ES, value: "es"
      value :LOCAL, value: "local"
      value :ES_STREET, value: "es_street"
      value :ES_PREDICATES, value: "es_predicates"
      value :ES_STREET_PREDICATES, value: "es_street_predicates"
    end
  end
end
