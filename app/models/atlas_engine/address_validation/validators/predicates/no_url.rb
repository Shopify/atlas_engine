# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class NoUrl < Predicate
          sig { override.returns(T.nilable(Concern)) }
          def evaluate
            return unless @cache.country.country?

            build_concern if contains_url(address.send(@field))
          end

          private

          sig { returns(Concern) }
          def build_concern
            Concern.new(
              field_names: [@field],
              code: "#{@field}_contains_url".to_sym,
              type: T.must(Concern::TYPES[:error]),
              type_level: 3,
              suggestion_ids: [],
              message: @cache.country.field(key: @field).error(code: :contains_url).to_s,
            )
          end

          sig { params(field_value: T.nilable(String)).returns(T::Boolean) }
          def contains_url(field_value)
            field_value.to_s.scan(%r{(http|https)?:\/\/|[\w-]{2,63}\.[a-zA-Z]{2,63}/}).any?
          end
        end
      end
    end
  end
end
