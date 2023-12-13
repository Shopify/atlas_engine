# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Types
    module AddressValidation
      class ConcernType < BaseObject
        description "A piece of relevant information regarding the address validation result." \
          "They can be categorized as either a Warning or Error."

        field :field_names, [String], null: false
        field :message, String, null: false
        field :code, String, null: false
        field :type, Enums::ConcernEnum, null: false
        field :type_level, Int, null: false
        field :suggestion_ids, [String], null: false
      end
    end
  end
end
