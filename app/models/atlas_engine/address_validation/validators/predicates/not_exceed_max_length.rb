# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class NotExceedMaxLength < Predicate
          MAX_COMPONENT_LENGTH = 255
          sig { override.returns(T.nilable(Concern)) }
          def evaluate
            return unless @cache.country.country?

            build_concern if address.send(@field).to_s.length > MAX_COMPONENT_LENGTH
          end

          private

          sig { returns(Concern) }
          def build_concern
            Concern.new(
              field_names: [@field],
              code: "#{@field}_too_long".to_sym,
              type: T.must(Concern::TYPES[:error]),
              type_level: 3,
              suggestion_ids: [],
              message: @cache.country.field(key: @field)&.error(code: :too_long).to_s,
            )
          end
        end
      end
    end
  end
end
