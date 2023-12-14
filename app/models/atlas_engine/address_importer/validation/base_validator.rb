# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module Validation
      class BaseValidator
        extend T::Sig

        Errors = T.type_alias { T::Hash[Symbol, T.untyped] }

        attr_reader :allow_partial_zip, :field_validations, :additional_field_validations

        sig do
          params(
            country_code: String,
            field_validations: T::Hash[Symbol, T::Array[FieldValidations::Interface]],
            additional_field_validations: T::Hash[Symbol, T::Array[FieldValidations::Interface]],
          ).void
        end
        def initialize(country_code:, field_validations:, additional_field_validations: {})
          @allow_partial_zip = T.let(CountryProfile.partial_zip_allowed_countries.include?(country_code), T::Boolean)
          @field_validations = field_validations
          @additional_field_validations = additional_field_validations.transform_values do |validator_classes|
            validator_classes.map do |validator_class|
              if validator_class.is_a?(Class)
                validator_class
              else
                validator_class.to_s.constantize
              end
            end
          end

          @caches = {}
          merged_field_validations.map do |field, _validator_class|
            @caches[field] = Set.new
          end

          @errors = T.let(Hash.new([]), Errors)
        end

        sig { params(address: AddressImporter::Validation::Wrapper::AddressStruct).returns(Errors) }
        def validation_errors(address:)
          validate(address: address)
          @errors
        end

        private

        sig { returns(T::Hash[Symbol, T::Array[FieldValidations::Interface]]) }
        def merged_field_validations
          @merged_field_validations ||= @field_validations.merge(@additional_field_validations) do
            |_field, validator_class, additional_validator_class|

            [validator_class, additional_validator_class].flatten.compact.uniq
          end
        end

        sig { params(address: AddressImporter::Validation::Wrapper::AddressStruct).void }
        def validate(address:)
          clear_errors

          merged_field_validations.each do |field, validators|
            if @caches[field].exclude?(address[field])
              @errors[field] = [].tap do |error_msgs|
                validators.each do |validator_class|
                  validator = T.unsafe(validator_class).new(address: address, allow_partial_zip: allow_partial_zip)
                  error_msgs << validator.validation_errors
                end
              end.flatten
            end

            break if @errors[field].present?

            @caches[field].add(address[field])
          end
        end

        sig { void }
        def clear_errors
          @errors = Hash.new([])
        end
      end
    end
  end
end
