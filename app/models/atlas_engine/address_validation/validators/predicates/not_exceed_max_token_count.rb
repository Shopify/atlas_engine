# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class NotExceedMaxTokenCount < Predicate
          MAX_TOKEN_COUNT = 15

          sig { override.returns(T.nilable(Concern)) }
          def evaluate
            tokens = extract_address_tokens_from(address.send(@field))
            build_concern if tokens.present? && tokens.count >= MAX_TOKEN_COUNT
          end

          private

          sig { returns(Concern) }
          def build_concern
            message_field = @cache.country.field(key: @field)
            message_arguments = {
              code: :contains_too_many_words,
              options: { word_count: MAX_TOKEN_COUNT },
            }
            if @field.in?([:address1, :address2])
              build_specific_concern(
                type: :warning,
                message: message_field.warning(**message_arguments).to_s,
              )
            else
              build_specific_concern(
                type: :error,
                message: message_field.error(**message_arguments).to_s,
              )
            end
          end

          sig { params(type: Symbol, message: String).returns(Concern) }
          def build_specific_concern(type:, message:)
            Concern.new(
              field_names: [@field],
              code: "#{@field}_contains_too_many_words".to_sym,
              type: T.must(Concern::TYPES[type]),
              type_level: 3,
              suggestion_ids: [],
              message: message,
            )
          end

          sig { params(value: T.nilable(String)).returns(T::Array[String]) }
          def extract_address_tokens_from(value)
            Annex29.segment_words(value).filter_map do |substring|
              next unless substring.match?(/\w/)

              substring
            end
          end
        end
      end
    end
  end
end
