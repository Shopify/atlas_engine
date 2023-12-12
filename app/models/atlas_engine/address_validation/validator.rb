# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Validator
      include RunsValidation
      extend T::Sig

      sig { returns(T.nilable(String)) }
      attr_reader :address1,
        :address2,
        :city,
        :province_code,
        :zip,
        :country_code,
        :phone

      sig { returns(Result) }
      attr_reader :result

      sig { returns(AbstractAddress) }
      attr_reader :address

      sig { returns(T::Hash[T.untyped, T.untyped]) }
      attr_reader :context

      sig { returns(T.nilable(FullAddressValidatorBase)) }
      attr_reader :full_address_validator

      FIELD_MAP = T.let(
        {
          country: "country_code",
          province: "province_code",
          zip: "zip",
          city: "city",
          address1: "address1",
          address2: "address2",
          phone: "phone",
        },
        T::Hash[Symbol, String],
      )

      sig do
        params(
          address: AbstractAddress,
          matching_strategy: Strategies,
          locale: String,
          context: T::Hash[T.untyped, T.untyped],
        ).void
      end
      def initialize(
        address:,
        matching_strategy:,
        locale: "en",
        context: {}
      )
        @address = T.let(address, AbstractAddress)
        @address1 = T.let(address.address1, T.nilable(String))
        @address2 = T.let(address.address2, T.nilable(String))
        @city = T.let(address.city, T.nilable(String))
        @province_code = T.let(address.province_code, T.nilable(String))
        @phone = T.let(address.phone, T.nilable(String))
        @zip = T.let(address.zip, T.nilable(String))
        @country_code = T.let(address.country_code, T.nilable(String))
        @context = T.let(context, T::Hash[T.untyped, T.untyped])
        @matching_strategy = T.let(matching_strategy, Strategies)

        matching_strategy_name = matching_strategy.serialize
        @predicate_pipeline = T.let(PredicatePipeline.find(matching_strategy_name), PredicatePipeline)

        @result = T.let(
          Result.new(
            client_request_id: context.dig(:client_request_id),
            origin: context.dig(:origin),
            locale: locale,
            matching_strategy: matching_strategy_name,
          ),
          Result,
        )

        @full_address_validator = T.let(
          @predicate_pipeline.full_address_validator&.new(
            address: @address,
            result: @result,
          ),
          T.nilable(FullAddressValidatorBase),
        )
      end

      sig { override.returns(Result) }
      def run
        build_fields

        populate_result(execute_pipeline)

        validate_full_address

        result
      end

      sig { void }
      def build_fields
        result.fields = address.keys.map do |field|
          Field.new(name: field, value: address[field])
        end
      end

      private

      sig { returns(T::Hash[Symbol, T::Array[Concern]]) }
      def execute_pipeline
        pipeline_address = Address.from_address(address: address)
        local_concerns = {}
        cache = Validators::Predicates::Cache.new(pipeline_address)
        @predicate_pipeline.pipeline.each do |config|
          local_concerns[config.field] = [] if local_concerns[config.field].nil?
          next if local_concerns[config.field].present?

          concern = config.class_name.new(field: config.field, address: pipeline_address, cache: cache).evaluate

          local_concerns[config.field] << concern if concern.present?
        end
        local_concerns
      end

      sig { params(local_concerns: T::Hash[Symbol, T::Array[Concern]]).void }
      def populate_result(local_concerns)
        local_concerns.keys.each do |field|
          if local_concerns[field]&.empty? && [:address2, :phone].exclude?(field)
            result.validation_scope << T.must(FIELD_MAP[field])
          end

          local_concerns[field]&.each do |concern|
            result.concerns << concern
            result.suggestions << T.must(concern.suggestion) if concern.suggestion.present?
          end
        end
      end

      sig { void }
      def validate_full_address
        @full_address_validator&.validate
      end
    end
  end
end
