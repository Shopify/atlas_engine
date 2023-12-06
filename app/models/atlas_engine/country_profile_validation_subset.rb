# typed: true
# frozen_string_literal: true

module AtlasEngine
  class CountryProfileValidationSubset < CountryProfileSubsetBase
    sig { returns(T::Boolean) }
    def enabled
      !!attributes.dig("enabled")
    end

    sig { returns(T.nilable(String)) }
    def default_matching_strategy
      attributes.dig("default_matching_strategy")
    end

    # PENDING: enable sig once move complete
    # sig do
    #   params(component: String)
    #     .returns(T::Array[T.class_of(AddressValidation::Validators::FullAddress::Exclusions::ExclusionBase)])
    # end
    def validation_exclusions(component:)
      validation_exclusions = attributes.dig("exclusions", component) || []
      validation_exclusions.map(&:constantize)
    end

    sig { params(length: Integer).returns(T.nilable(T::Range[T.untyped])) }
    def partial_postal_code_range(length)
      range = attributes.dig("partial_postal_code_range_for_length", length)
      return unless range

      Range.new(*range.split("..").map(&:to_i))
    end

    sig { returns(T::Array[T.nilable(Symbol)]) }
    def script_restrictions
      attributes.dig("script_restrictions")&.map(&:to_sym) || []
    end


    # PENDING: enable sig once move complete
    # sig { returns(T::Class[ValidationTranscriber::AddressParserBase]) }
    def address_parser
      # rubocop:disable Sorbet/ConstantsFromStrings
      attributes.dig("address_parser").constantize
      # rubocop:enable Sorbet/ConstantsFromStrings
    end

    # PENDING: enable sig once move complete
    # sig { returns(T::Hash[Symbol, T::Class[AddressLookup::Base]]) }
    def carrier_address_lookups
      attributes.dig("admin", "carrier_address_lookups").transform_values(&:constantize)
    end
  end
end
