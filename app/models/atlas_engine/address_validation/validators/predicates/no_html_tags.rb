# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class NoHtmlTags < Predicate
          sig { override.returns(T.nilable(Concern)) }
          def evaluate
            return unless @cache.country.country?

            build_concern if contains_html_tags(address.send(@field))
          end

          private

          sig { returns(Concern) }
          def build_concern
            Concern.new(
              field_names: [@field],
              code: "#{@field}_contains_html_tags".to_sym,
              type: T.must(Concern::TYPES[:error]),
              type_level: 3,
              suggestion_ids: [],
              message: @cache.country.field(key: @field).error(code: :contains_html_tags).to_s,
            )
          end

          sig { params(field_value: T.nilable(String)).returns(T::Boolean) }
          def contains_html_tags(field_value)
            sanitized_field_value = ActionView::Base.full_sanitizer.sanitize(field_value)
            field_value.to_s != HTMLEntities.new.decode(sanitized_field_value)
          end
        end
      end
    end
  end
end
