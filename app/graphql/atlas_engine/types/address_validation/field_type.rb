# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Types
    module AddressValidation
      class FieldType < BaseObject
        description "An individual field which in conjunction with others compose an address"

        field :name, String, null: false
        field :value, String, null: false
      end
    end
  end
end
