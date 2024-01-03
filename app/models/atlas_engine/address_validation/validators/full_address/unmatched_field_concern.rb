# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnmatchedFieldConcern < AddressValidation::Concern
          include ConcernFormatter
          attr_reader :component, :matched_components, :address, :unmatched_field

          COMPONENTS_TO_LABELS = {
            zip: "ZIP",
            province_code: "state",
            city: "city",
            street: "street name",
          }.freeze

          SHORTENED_COMPONENT_NAMES = {
            province_code: :province,
          }.freeze

          sig do
            params(
              unmatched_component: Symbol,
              matched_components: T::Array[Symbol],
              address: AbstractAddress,
              suggestion_ids: T::Array[String],
              unmatched_field: T.nilable(Symbol),
            ).void
          end
          def initialize(unmatched_component, matched_components, address, suggestion_ids, unmatched_field = nil)
            @component = unmatched_component
            @matched_components = matched_components
            @address = address
            @unmatched_field = unmatched_field

            super(
              code: code,
              field_names: field_names,
              message: message,
              type: T.must(Concern::TYPES[:warning]),
              type_level: 3,
              suggestion_ids: suggestion_ids
            )
          end

          sig { returns(String) }
          def message
            "Enter a valid #{COMPONENTS_TO_LABELS[component]} for #{valid_address_component_values.join(", ")}"
          end

          sig { returns(Symbol) }
          def code
            "#{shortened_component_name}_inconsistent".to_sym
          end

          sig { returns(T::Array[Symbol]) }
          def field_names
            [field_name]
          end

          private

          sig { returns(T::Array[String]) }
          def valid_address_component_values
            matched_components.last(2).map do |component|
              component == :province_code ? province_name : address[component]
            end
          end

          sig { returns(Symbol) }
          def shortened_component_name
            SHORTENED_COMPONENT_NAMES[component] || component
          end

          def field_name
            unmatched_field || shortened_component_name
          end
        end
      end
    end
  end
end
