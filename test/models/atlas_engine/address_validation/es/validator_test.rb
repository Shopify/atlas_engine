# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Es
      class ValidatorTest < ActiveSupport::TestCase
        include AddressValidationTestHelper

        test "returns expected values" do
          address = build_address(
            address1: "777 Pacific Blvd",
            city: "Vancouver",
            province_code: "BC",
            zip: "V6B 4Y8",
            country_code: "CA",
          )

          expected_result = {
            fields: [
              { name: :address1, value: address.address1 },
              { name: :address2, value: address.address2 },
              { name: :city, value: address.city },
              { name: :province_code, value: address.province_code },
              { name: :zip, value: address.zip },
              { name: :country_code, value: address.country_code },
              { name: :phone, value: address.phone },
            ],
            concerns: [
              {
                field_names: [:address1],
                message: I18n.t("worldwide._default.addresses.address.errors.may_not_exist"),
                code: :address_unknown,
                type: "warning",
                type_level: 1,
                suggestion_ids: [],
              },
            ],
            suggestions: [],
            validation_scope: ["country_code", "province_code", "zip", "city", "address1"],
            locale: "en",
          }

          stub_request(:post, %r{http\://.*/test_ca/_analyze})
            .to_return(
              status: 200,
              body: { "tokens": [] }.to_json,
              headers: { "Content-Type" => "application/json" },
            )
          stub_request(:post, %r{http\://.*/test_ca/_search})
            .to_return(
              status: 200,
              body: { "hits": { "hits": [] } }.to_json,
              headers: { "Content-Type" => "application/json" },
            )

          validator = AddressValidation::Validator.new(
            address: address,
            matching_strategy: MatchingStrategies::EsStreet,
          )
          result = validator.run
          result = result.attributes

          assert_equal expected_result[:fields], result[:fields]
          assert_equal expected_result[:concerns], result[:concerns]
          assert_equal expected_result[:suggestions], result[:suggestions]
          assert_equal expected_result[:validation_scope], result[:validation_scope]
          assert_equal expected_result[:locale], result[:locale]

          validator.full_address_validator.session.datastore.fetch_city_sequence
          validator.full_address_validator.session.datastore.fetch_street_sequences

          assert_requested(:post, %r{http\://.*/test_ca/_analyze}, times: 2)
          assert_requested(:post, %r{http\://.*/test_ca/_search}, times: 1)
        end

        test "validates country" do
          address = build_address(
            address1: "777 Pacific Blvd",
            city: "Vancouver",
            province_code: "BC",
            zip: "V6B 4Y8",
            country_code: nil,
          )

          expected_result = {
            fields: [
              { name: :address1, value: address.address1 },
              { name: :address2, value: address.address2 },
              { name: :city, value: address.city },
              { name: :province_code, value: address.province_code },
              { name: :zip, value: address.zip },
              { name: :country_code, value: address.country_code },
              { name: :phone, value: address.phone },
            ],
            concerns: [
              {
                field_names: [:country],
                message: I18n.t("worldwide._default.addresses.country.errors.blank"),
                code: :country_blank,
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              },
            ],
            suggestions: [],
            validation_scope: [],
            locale: "en",
          }

          result = AddressValidation::Validator.new(address: address, matching_strategy: MatchingStrategies::Es).run
          result = result.attributes

          assert_equal expected_result[:fields], result[:fields]
          assert_equal expected_result[:concerns], result[:concerns]

          verify_es_not_called
        end

        test "validates province code" do
          address = build_address(
            address1: "777 Pacific Blvd",
            city: "Vancouver",
            province_code: nil,
            zip: "V6B 4Y8",
            country_code: "CA",
          )

          expected_result = {
            fields: [
              { name: :address1, value: address.address1 },
              { name: :address2, value: address.address2 },
              { name: :city, value: address.city },
              { name: :province_code, value: address.province_code },
              { name: :zip, value: address.zip },
              { name: :country_code, value: address.country_code },
              { name: :phone, value: address.phone },
            ],
            concerns: [
              {
                field_names: [:province],
                message: I18n.t("worldwide.CA.addresses.province.errors.blank"),
                code: :province_blank,
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              },
            ],
            suggestions: [],
            validation_scope: [],
            locale: "en",
          }

          result = AddressValidation::Validator.new(address: address, matching_strategy: MatchingStrategies::Es).run
          result = result.attributes

          assert_equal expected_result[:fields], result[:fields]
          assert_equal expected_result[:concerns], result[:concerns]

          verify_es_not_called
        end

        test "validates city" do
          address = build_address(
            address1: "777 Pacific Blvd",
            city: nil,
            province_code: "BC",
            zip: "V6B 4Y8",
            country_code: "CA",
          )

          expected_result = {
            fields: [
              { name: :address1, value: address.address1 },
              { name: :address2, value: address.address2 },
              { name: :city, value: address.city },
              { name: :province_code, value: address.province_code },
              { name: :zip, value: address.zip },
              { name: :country_code, value: address.country_code },
              { name: :phone, value: address.phone },
            ],
            concerns: [
              {
                field_names: [:city],
                message: I18n.t("worldwide._default.addresses.city.errors.blank"),
                code: :city_blank,
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              },
            ],
            suggestions: [],
            validation_scope: [],
            locale: "en",
          }

          result = AddressValidation::Validator.new(address: address, matching_strategy: MatchingStrategies::Es).run
          result = result.attributes

          assert_equal expected_result[:fields], result[:fields]
          assert_equal expected_result[:concerns], result[:concerns]

          verify_es_not_called
        end

        test "validates zip code" do
          address = build_address(
            address1: "777 Pacific Blvd",
            city: "Vancouver",
            province_code: "BC",
            zip: nil,
            country_code: "CA",
          )

          expected_result = {
            fields: [
              { name: :address1, value: address.address1 },
              { name: :address2, value: address.address2 },
              { name: :city, value: address.city },
              { name: :province_code, value: address.province_code },
              { name: :zip, value: address.zip },
              { name: :country_code, value: address.country_code },
              { name: :phone, value: address.phone },
            ],
            concerns: [
              {
                field_names: [:zip],
                message: I18n.t(
                  "worldwide._default.addresses.zip.errors.invalid_for_province",
                  province: "British Columbia",
                ),
                code: :zip_blank,
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              },
            ],
            suggestions: [],
            validation_scope: [],
            locale: "en",
          }

          result = AddressValidation::Validator.new(address: address, matching_strategy: MatchingStrategies::Es).run
          result = result.attributes

          assert_equal expected_result[:fields], result[:fields]
          assert_equal expected_result[:concerns], result[:concerns]

          verify_es_not_called
        end

        test "validates street address" do
          address = build_address(
            address1: nil,
            city: "Vancouver",
            province_code: "BC",
            zip: "V6B 4Y8",
            country_code: "CA",
          )

          expected_result = {
            fields: [
              { name: :address1, value: address.address1 },
              { name: :address2, value: address.address2 },
              { name: :city, value: address.city },
              { name: :province_code, value: address.province_code },
              { name: :zip, value: address.zip },
              { name: :country_code, value: address.country_code },
              { name: :phone, value: address.phone },
            ],
            concerns: [
              {
                field_names: [:address1],
                message: I18n.t("worldwide._default.addresses.address1.errors.blank"),
                code: :address1_blank,
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              },
            ],
            suggestions: [],
            validation_scope: [],
            locale: "en",
          }

          result = AddressValidation::Validator.new(address: address, matching_strategy: MatchingStrategies::Es).run
          result = result.attributes

          assert_equal expected_result[:fields], result[:fields]
          assert_equal expected_result[:concerns], result[:concerns]

          verify_es_not_called
        end

        def verify_es_not_called
          assert_requested(:get, %r{http\://.*/test_ca/_analyze}, times: 0)
          assert_requested(:get, %r{http\://.*/test_ca/_search}, times: 0)
        end
      end
    end
  end
end
