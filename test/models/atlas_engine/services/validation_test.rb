# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Services
    class ValidationTest < ActiveSupport::TestCase
      include StatsD::Instrument::Assertions
      include AddressValidation::AddressValidationTestHelper

      class DummyValidator
        include AddressValidation::RunsValidation

        def run = AddressValidation::Result.new
      end

      def dummy_validator = DummyValidator.new

      setup do
        @country_code = "CA"
        @locale = "en"
        @address = "123 Test St"
        @address_input = build_address(country_code: @country_code)
      end

      test "#validate_address when \"local\" matching strategy, calls validator with local" do
        request = AddressValidation::Request.new(
          address: @address_input,
          locale: "en",
          matching_strategy: "local",
        )

        AddressValidation::StatsdEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::LogEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::Validator.expects(:new).with(has_entries(
          matching_strategy: AddressValidation::MatchingStrategies::Local,
        ))
          .once.returns(dummy_validator)

        Services::Validation.validate_address(request)
      end

      test "#validate_address with \"es\" matching strategy, calls validator if validation enabled" do
        request = AddressValidation::Request.new(
          address: @address_input,
          locale: "en",
          matching_strategy: "es",
        )

        CountryProfile.expects(:for).with(@country_code).returns(mock(validation: mock(enabled: true)))
        AddressValidation::StatsdEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::LogEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::Validator.expects(:new)
          .with(has_entries(
            matching_strategy: AddressValidation::MatchingStrategies::Es,
          ))
          .once.returns(dummy_validator)

        Services::Validation.validate_address(request)
      end

      test "#validate_address with \"es_street\" matching strategy calls validator if validation enabled" do
        request = AddressValidation::Request.new(
          address: @address_input,
          locale: "en",
          matching_strategy: "es_street",
        )

        CountryProfile.expects(:for).with(@country_code).returns(mock(validation: mock(enabled: true)))
        AddressValidation::StatsdEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::LogEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::Validator.expects(:new)
          .with(has_entries(
            matching_strategy: AddressValidation::MatchingStrategies::EsStreet,
          ))
          .once.returns(dummy_validator)

        Services::Validation.validate_address(request)
      end

      test "#validate_address when matching strategy not provided use default from country profile" do
        default_matching_strategy = "es_street"

        validation = mock
        validation.stubs(:enabled).returns(true)
        validation.stubs(:default_matching_strategy).returns(default_matching_strategy)
        profile = mock
        CountryProfile.stubs(:for).with(@country_code).returns(profile)
        profile.stubs(:validation).returns(validation)

        request = AddressValidation::Request.new(
          address: @address_input,
          locale: "en",
        )

        AddressValidation::StatsdEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::LogEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::Validator.expects(:new)
          .with(has_entries(
            matching_strategy: AddressValidation::MatchingStrategies::EsStreet,
          ))
          .once.returns(dummy_validator)

        Services::Validation.validate_address(request)
      end

      test "#validate_address matching strategy value is case insensitive" do
        request = AddressValidation::Request.new(
          address: @address_input,
          locale: "en",
          matching_strategy: "LOCAL",
        )

        AddressValidation::StatsdEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::LogEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::Validator.expects(:new)
          .with(has_entries(
            matching_strategy: AddressValidation::MatchingStrategies::Local,
          ))
          .once.returns(dummy_validator)

        Services::Validation.validate_address(request)
      end

      test "#validate_address matching strategy value is a symbol" do
        request = AddressValidation::Request.new(
          address: @address_input,
          locale: "en",
          matching_strategy: :local,
        )

        AddressValidation::StatsdEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::LogEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::Validator.expects(:new)
          .with(has_entries(
            matching_strategy: AddressValidation::MatchingStrategies::Local,
          ))
          .once.returns(dummy_validator)
        Services::Validation.validate_address(request)
      end

      test "#validate_address translates the result according to the given locale" do
        @address_input = build_address(
          # Gyeongbokgung Palace
          address1: "사직로 161", # 161 Sajik-ro
          city: "종로구", # Jongno-gu
          province_code: "KR-11", # Seoul
          country_code: "KR",
          zip: "47333", # This is in Busan, the other end of the country, therefore invalid for Seoul
        )

        request = AddressValidation::Request.new(
          address: @address_input,
          locale: "ko",
          matching_strategy: :LOCAL,
        )

        AddressValidation::StatsdEmitter.expects(:new).returns(mock(run: nil)).once
        AddressValidation::LogEmitter.expects(:new).returns(mock(run: nil)).once

        result = Services::Validation.validate_address(request)
        concern = result.concerns.first

        assert_equal "서울특별시의 유효한 우편 번호 입력", concern.message
        assert_equal :zip_invalid_for_province, concern.code
        assert_equal "ko", result.locale
      end

      test "#validate_address caches concerns only if config = true" do
        original_config_value = Rails.configuration.x.captured_concerns.enabled
        Rails.configuration.x.captured_concerns.enabled = true

        request = AddressValidation::Request.new(
          address: @address_input,
          locale: "en",
          matching_strategy: :LOCAL,
        )

        AddressValidation::StatsdEmitter.stubs(:new).returns(mock(run: nil))
        AddressValidation::LogEmitter.stubs(:new).returns(mock(run: nil))
        AddressValidation::Validator.expects(:new)
          .with(has_entries(
            matching_strategy: AddressValidation::MatchingStrategies::Local,
          ))
          .once.returns(dummy_validator)

        AddressValidation::ConcernProducer.expects(:add).once

        Services::Validation.validate_address(request)
      ensure
        Rails.configuration.x.captured_concerns.enabled = original_config_value
      end
    end
  end
end
