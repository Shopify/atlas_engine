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

    sig { returns(T::Array[String]) }
    def index_locales
      attributes.dig("index_locales") || []
    end

    sig { returns(T::Boolean) }
    def multi_locale?
      index_locales.size > 1
    end

    sig do
      params(component: Symbol)
        .returns(T::Array[T.class_of(AddressValidation::Validators::FullAddress::Exclusions::ExclusionBase)])
    end
    def validation_exclusions(component:)
      validation_exclusions = attributes.dig("exclusions", component.to_s) || []
      validation_exclusions.map(&:constantize)
    end

    sig { params(length: Integer).returns(T.nilable(T::Range[T.untyped])) }
    def partial_postal_code_range(length)
      range = attributes.dig("partial_postal_code_range_for_length", length)
      return unless range

      Range.new(*range.split("..").map(&:to_i))
    end

    sig { returns(T::Class[ValidationTranscriber::AddressParserBase]) }
    def address_parser
      attributes.dig("address_parser").constantize
    end

    sig { returns(T::Array[String]) }
    def normalized_components
      attributes.dig("normalized_components") || []
    end

    sig { params(field: Symbol).returns(AddressValidation::Token::Sequence::ComparisonPolicy) }
    def comparison_policy(field)
      field_policy = attributes.dig(
        "comparison_policies",
        field.to_s,
      )&.deep_symbolize_keys&.deep_transform_values!(&:to_sym)

      if field_policy.present?
        AddressValidation::Token::Sequence::ComparisonPolicy.new(**field_policy)
      else
        AddressValidation::Token::Sequence::ComparisonPolicy::DEFAULT_POLICY
      end
    end
  end
end
