# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module Validation
      module FieldValidations
        class City
          extend T::Sig
          extend T::Helpers
          include Interface

          sig do
            override.params(
              address: AddressImporter::Validation::Wrapper::AddressStruct,
              allow_partial_zip: T::Boolean,
            ).void
          end
          def initialize(address:, allow_partial_zip: false)
            @city = address.city
            @errors = []
          end

          sig { override.returns(T::Array[String]) }
          def validation_errors
            clear_errors
            validate
            errors
          end

          private

          attr_reader :city
          attr_accessor :errors

          def clear_errors
            self.errors = []
          end

          def validate
            errors << "City is required" unless city&.any?(&:present?)
          end
        end
      end
    end
  end
end
