# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Types
    module AddressValidation
      module Enums
        class ConcernEnum < BaseEnum
          value :WARNING, value: "warning"
          value :ERROR, value: "error"
        end
      end
    end
  end
end
