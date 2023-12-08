# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class ConcernRecord
      extend T::Sig

      sig { returns(String) }
      attr_reader :address1

      sig { returns(String) }
      attr_reader :address2

      sig { returns(String) }
      attr_reader :city

      sig { returns(String) }
      attr_reader :country_code

      sig { returns(String) }
      attr_reader :province_code

      sig { returns(String) }
      attr_reader :zip

      sig { returns(String) }
      attr_reader :phone

      sig { returns(Result) }
      attr_reader :result

      sig { returns(T.nilable(String)) }
      attr_reader :version

      sig { returns(T.nilable(String)) }
      attr_reader :request_id

      sig { returns(T.nilable(String)) }
      attr_reader :client_request_id

      sig { returns(Time) }
      attr_reader :timestamp

      sig { returns(String) }
      attr_reader :origin

      class << self
        extend T::Sig

        sig { params(result: Result, context: T::Hash[T.untyped, T.untyped]).returns(ConcernRecord) }
        def from_result(result, context = {})
          new(
            **T.unsafe(
              {
                result: result,
                **result.address,
                **context.except(:client_request_id),
              },
            ),
          )
        end
      end

      sig do
        params(
          request_id: T.nilable(String),
          timestamp: Time,
          origin: String,
          address1: String,
          address2: String,
          city: String,
          province_code: String,
          country_code: String,
          zip: String,
          phone: String,
          result: Result,
        ).void
      end
      def initialize(
        request_id: nil,
        timestamp: Time.zone.now,
        origin: "",
        address1: "",
        address2: "",
        city: "",
        province_code: "",
        country_code: "",
        zip: "",
        phone: "",
        result: Result.new
      )
        @request_id = request_id
        @client_request_id = T.let(result.client_request_id, T.nilable(String))
        @timestamp = timestamp
        @origin = origin
        @address1 = address1
        @address2 = address2
        @city = city
        @province_code = province_code
        @country_code = country_code
        @zip = zip
        @phone = phone
        @result = result
        @version = T.let(Rails.configuration.version, T.nilable(String))
      end

      sig { returns(T::Hash[Symbol, String]) }
      def address_attributes
        {
          address1: address1,
          address2: address2,
          city: city,
          province_code: province_code,
          zip: zip,
          country_code: country_code,
          phone: phone,
        }
      end
    end
  end
end
