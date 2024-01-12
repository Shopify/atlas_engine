# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module ValidationTranscriber
    class AddressParserFactoryTest < ActiveSupport::TestCase
      test "create raises an error if country_code is nil" do
        assert_raises(ArgumentError) do
          AddressParserFactory.create(address: AddressValidation::Address.new)
        end
      end

      test "create raises an error if locale is not provided for a multi-locale country" do
        profile_attributes = {
          "id" => "CH",
          "validation" => {
            "key" => "some_value",
            "index_locales" => ["de", "fr"],
            "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserBase",
          },
        }
        CountryProfile.any_instance.stubs(:attributes).returns(profile_attributes)

        assert_raises(ArgumentError) do
          AddressParserFactory.create(address: AddressValidation::Address.new(country_code: "CH"))
        end
      end

      test "returns address parser if locale is provided for a multi-locale country" do
        profile_attributes = {
          "id" => "CH_DE",
          "validation" => {
            "key" => "some_value",
            "index_locales" => ["de", "fr"],
            "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserBase",
          },
        }
        CountryProfile.expects(:for).with("CH", "de").returns(CountryProfile.new(profile_attributes))

        parser = AddressParserFactory.create(address: AddressValidation::Address.new(country_code: "CH"), locale: "de")
        assert_instance_of(AddressParserBase, parser)
      end

      test "create returns an AddressParserBase for any given NON north american address" do
        profile_attributes = {
          "id" => "XX",
          "validation" => {
            "key" => "some_value",
            "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserBase",
          },
        }
        CountryProfile.any_instance.stubs(:attributes).returns(profile_attributes)

        parser = AddressParserFactory.create(address: fr_address)

        assert_instance_of(AddressParserBase, parser)
      end

      test "create returns an AddressParserNorthAmerica for any given US address" do
        profile_attributes = {
          "id" => "XX",
          "validation" => {
            "key" => "some_value",
            "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserNorthAmerica",
          },
        }
        CountryProfile.any_instance.stubs(:attributes).returns(profile_attributes)

        parser = AddressParserFactory.create(address: us_address)
        assert_instance_of(AddressParserNorthAmerica, parser)
      end

      test "create returns an AddressParserNorthAmerica for any given CA address" do
        profile_attributes = {
          "id" => "XX",
          "validation" => {
            "key" => "some_value",
            "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserNorthAmerica",
          },
        }
        CountryProfile.any_instance.stubs(:attributes).returns(profile_attributes)

        parser = AddressParserFactory.create(address: ca_address)

        assert_instance_of(AddressParserNorthAmerica, parser)
      end

      private

      def us_address
        AddressValidation::Address.new(
          address1: "123 Main Street",
          city: "San Francisco",
          province_code: "CA",
          country_code: "US",
          zip: "94102",
        )
      end

      def ca_address
        AddressValidation::Address.new(
          address1: "777 Pacific Blvd",
          city: "Vancouver",
          province_code: "BC",
          zip: "V6B 4Y8",
          country_code: "CA",
        )
      end

      def fr_address
        AddressValidation::Address.new(
          address1: "237 Rue de la Convention",
          zip: "75015",
          country_code: "FR",
          city: "Paris",
        )
      end
    end
  end
end
