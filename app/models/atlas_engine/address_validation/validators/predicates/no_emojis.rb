# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class NoEmojis < Predicate
          sig { override.returns(T.nilable(Concern)) }
          def evaluate
            return unless @cache.country.country?

            build_concern if contains_blocked_codepoints?(address.send(@field))
          end

          private

          sig { returns(Concern) }
          def build_concern
            Concern.new(
              field_names: [@field],
              code: "#{@field}_contains_emojis".to_sym,
              type: T.must(Concern::TYPES[:error]),
              type_level: 3,
              suggestion_ids: [],
              message: @cache.country.field(key: @field)&.error(code: :contains_emojis).to_s,
            )
          end

          sig { params(field_value: T.nilable(String)).returns(T::Boolean) }
          def contains_blocked_codepoints?(field_value)
            field_value.to_s.codepoints.any? { |x| (x > 0xffff) || (0x2190 <= x && x <= 0x2bff) }
          end
        end
      end
    end
  end
end
