# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class ValidationQueryTest < ActiveSupport::TestCase
    include StatsD::Instrument::Assertions

    class DummyValidator
      include AddressValidation::RunsValidation

      def run = AddressValidation::Result.new
    end

    def dummy_validator = DummyValidator.new

    test "when a proper address provided, returns expected response" do
      address = build_address(
        address1: "777 Pacific Blvd",
        city: "Vancouver",
        province_code: "BC",
        zip: "V6B 4Y8",
        country_code: "CA",
      )

      expected = {
        data: {
          validation: {
            validationScope: ["country_code", "province_code", "zip", "city", "address1"],
            locale: "en",
            fields: [
              { name: "address1", value: "777 Pacific Blvd" },
              { name: "city", value: "Vancouver" },
              { name: "country_code", value: "CA" },
              { name: "province_code", value: "BC" },
              { name: "zip", value: "V6B 4Y8" },
            ],
            concerns: [],
            suggestions: [],
          },
        },
      }

      assert_statsd_increment(
        "AddressValidation.valid",
        times: 1,
        tags: {
          country: "CA",
          component: "zip",
        },
      ) do
        result = Schema.execute(
          validation_query,
          variables: { address: address },
        ).to_h.deep_symbolize_keys
        assert_equal expected, result
      end

      assert_statsd_increment(
        "AddressValidation.valid",
        times: 1,
        tags: {
          country: "CA",
          component: "city",
        },
      ) do
        result = Schema.execute(
          validation_query,
          variables: { address: address },
        ).to_h.deep_symbolize_keys
        assert_equal expected, result
      end
    end

    test "correct validator called with matching_strategy: :LOCAL" do
      address = build_address(
        address1: "131 Greene St",
        city: "New York",
        province_code: "NY",
        zip: "10012",
        country_code: "US",
      )

      AddressValidation::Validator.expects(:new).returns(dummy_validator)
      Schema.execute(validation_query(matching_strategy: :LOCAL), variables: { address: address })
    end

    test "correct validator called with matching_strategy: :ES" do
      address = build_address(
        address1: "131 Greene St",
        city: "New York",
        province_code: "NY",
        zip: "10012",
        country_code: "US",
      )

      AddressValidation::Validator.expects(:new).with(has_keys(
        :address,
        :locale,
        :matching_strategy,
      )).returns(dummy_validator)
      Schema.execute(validation_query(matching_strategy: :ES), variables: { address: address })
    end

    test "correct validator called with matching_strategy: :ES_STREET" do
      address = build_address(
        address1: "131 Greene St",
        city: "New York",
        province_code: "NY",
        zip: "10012",
        country_code: "US",
      )

      AddressValidation::Validator.expects(:new).with(has_keys(
        :address,
        :locale,
        :matching_strategy,
      )).returns(dummy_validator)
      Schema.execute(validation_query(matching_strategy: :ES_STREET), variables: { address: address })
    end

    test "when an incomplete address provided, returns expected response" do
      address = build_address(city: "Vancouver", province_code: "BC", zip: "V6B 4Y8", country_code: "CA")
      address = address.except(:address1, :address2)

      expected = {
        data: {
          validation: {
            validationScope: ["country_code", "province_code", "zip", "city"],
            locale: "en",
            fields: [
              { name: "city", value: "Vancouver" },
              { name: "country_code", value: "CA" },
              { name: "province_code", value: "BC" },
              { name: "zip", value: "V6B 4Y8" },
            ],
            concerns: [
              {
                fieldNames: ["address1"],
                message: "Enter an address",
                code: "address1_blank",
                type: "ERROR",
                typeLevel: 3,
                suggestionIds: [],
              },
            ],
            suggestions: [],
          },
        },
      }

      result = Schema.execute(
        validation_query(matching_strategy: :LOCAL),
        variables: { address: address },
      ).to_h.deep_symbolize_keys

      assert_equal expected, result
    end

    test "when an invalid phone provided, returns expected response" do
      address = build_address(
        address1: "777 Pacific Blvd",
        city: "Vancouver",
        province_code: "BC",
        zip: "V6B 4Y8",
        country_code: "CA",
        phone: "046626000",
      )

      expected = {
        data: {
          validation: {
            validationScope: ["country_code", "province_code", "zip", "city", "address1"],
            locale: "en",
            fields: [
              { name: "address1", value: "777 Pacific Blvd" },
              { name: "city", value: "Vancouver" },
              { name: "country_code", value: "CA" },
              { name: "province_code", value: "BC" },
              { name: "zip", value: "V6B 4Y8" },
              { name: "phone", value: "046626000" },
            ],
            concerns: [
              {
                fieldNames: ["phone"],
                code: "phone_invalid",
                message: "Enter a valid phone number",
                type: "ERROR",
                typeLevel: 3,
                suggestionIds: [],
              },
            ],
            suggestions: [],
          },
        },
      }

      result = Schema.execute(
        validation_query(matching_strategy: :LOCAL),
        variables: { address: address },
      ).to_h.deep_symbolize_keys

      assert_equal expected, result
    end

    test "when an empty address provided, returns error message" do
      address = {}
      result = Schema.execute(
        validation_query(matching_strategy: :LOCAL),
        variables: { address: address },
      ).to_h.deep_symbolize_keys

      assert_equal "The given request is missing a required parameter.", result[:errors].first[:message]
    end

    test "when no country provided, returns error message" do
      address = build_address(country_code: "XX")
      result = Schema.execute(
        validation_query(matching_strategy: :LOCAL),
        variables: { address: address },
      ).to_h.deep_symbolize_keys

      assert_match "was provided invalid value for countryCode", result[:errors].first[:message]
    end

    test "translates the concern message according to the locale" do
      address = build_address(city: "Vancouver", province_code: "BC", zip: "V6B 4Y8", country_code: "CA")
      address = address.except(:address1, :address2)

      expected = {
        data: {
          validation: {
            validationScope: ["country_code", "province_code", "zip", "city"],
            locale: "fr",
            fields: [
              { name: "city", value: "Vancouver" },
              { name: "country_code", value: "CA" },
              { name: "province_code", value: "BC" },
              { name: "zip", value: "V6B 4Y8" },
            ],
            concerns: [
              {
                fieldNames: ["address1"],
                message: "Saisir une adresse",
                code: "address1_blank",
                type: "ERROR",
                typeLevel: 3,
                suggestionIds: [],
              },
            ],
            suggestions: [],
          },
        },
      }

      result = Schema.execute(
        validation_query(matching_strategy: :LOCAL, locale: "fr"),
        variables: { address: address },
      ).to_h.deep_symbolize_keys

      assert_equal expected, result
    end

    private

    def validation_query(locale: "en", matching_strategy: :LOCAL)
      "query validation($address: AddressInput!) {
        validation(address: $address,
          locale: \"#{locale.upcase}\",
          matchingStrategy: #{matching_strategy}
        ) {
          validationScope
          locale
          fields {
            name
            value
          }
          concerns {
            fieldNames
            message
            code
            type
            typeLevel
            suggestionIds
          }
          suggestions {
            id
            address1
            address2
            city
            zip
            provinceCode
            countryCode
          }
        }
      }"
    end

    # NOTE:  These methods look like duplicates of methods with the same name in other files.
    # Unfortunately, that is not the case.  These methods operate on mocks of the GraphQL
    # Address object, which differs from the address validation Address object in a few aspects,
    # such as using address[:countryCode] instead of address.country_code.  :sad_panda:

    def build_address(address1: "", address2: "", city: "", province_code: "", zip: "", country_code: "", phone: "")
      address = {}
      address[:address1] = address1 if address1.present?
      address[:address2] = address2 if address2.present?
      address[:city] = city if city.present?
      address[:provinceCode] = province_code if province_code.present?
      address[:zip] = zip if zip.present?
      address[:countryCode] = country_code if country_code.present?
      address[:phone] = phone if phone.present?
      address
    end
  end
end
