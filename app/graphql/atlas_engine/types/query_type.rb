# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Types
    class QueryType < Types::BaseObject
      include LogHelper

      field :validation, ValidationType, null: false do
        argument :address, AddressValidation::AddressInput, required: true
        argument :locale, String, required: true
        argument :matching_strategy, MatchingStrategyType, required: false
      end

      def validation(address:, locale: "en", matching_strategy: nil)
        raise build_graphql_error(AtlasEngine::AddressValidation::Errors::MISSING_PARAMETER) if address.blank?

        locale = LocaleFormatHelper.format_locale(locale)

        country_code = address.country_code
        tags = ["country:#{country_code}", "matching_strategy:#{matching_strategy}"]
        measure("validation", tags) do
          I18n.with_locale(locale) do
            Services::Validation.validate_address(
              AtlasEngine::AddressValidation::Request.new(
                address: address,
                locale: locale,
                matching_strategy: matching_strategy,
              ),
            )
          end
        end
      end

      private

      def measure(method, tags = [], value = nil, &block)
        if block
          StatsD.distribution(
            "#{method}.request_time",
            tags: tags,
            &block
          )
        else
          StatsD.distribution(
            "#{method}.request_time",
            value,
            tags: tags,
          )
        end
      end

      def build_graphql_error(error)
        GraphQL::ExecutionError.new(
          error.message,
          extensions: { "error_code" => error.code },
        )
      end
    end
  end
end
