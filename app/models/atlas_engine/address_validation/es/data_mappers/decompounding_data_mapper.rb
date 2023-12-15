# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      module DataMappers
        class DecompoundingDataMapper < DefaultDataMapper
          sig do
            override.returns(T::Hash[Symbol, T.untyped])
          end
          def map_data
            super.tap do |data|
              decompounded_fields.each do |field|
                data["#{field}_decompounded".to_sym] = decompound(field: field, value: data[field])
              end
            end
          end

          private

          sig { returns(T::Array[Symbol]) }
          def decompounded_fields
            country_profile.attributes.dig("decompounding_patterns").keys.map(&:to_sym)
          end

          sig { params(field: Symbol, value: T.nilable(String)).returns(T.nilable(String)) }
          def decompound(field:, value:)
            FieldDecompounder.new(
              field: field,
              value: value,
              country_profile: country_profile,
            ).call
          end
        end
      end
    end
  end
end
