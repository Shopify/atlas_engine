# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Types
    class MatchingStrategyType < BaseEnum
      value :ES, value: "es"
      value :LOCAL, value: "local"
      value :ES_STREET, value: "es_street"
    end
  end
end
