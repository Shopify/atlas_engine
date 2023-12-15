# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module ValidationTranscriber
    class AddressParserPreprocessorTest < ActiveSupport::TestCase
      include AddressValidation::AddressValidationTestHelper

      test "#initialize raises ArgumentError if country_code is not provided in address" do
        address = build_address(address1: "123 Main St")
        error = assert_raises(ArgumentError) do
          AddressParserPreprocessor.new(address: address)
        end
        assert_equal("country_code cannot be blank in address", error.message)
      end

      test "#generate_combinations returns empty array if no address componenets are provided" do
        @address_parser_preprocessor = AddressParserPreprocessor.new(
          address: build_address(country_code: :ca, address1: nil, address2: nil),
        )
        combinations = @address_parser_preprocessor.generate_combinations
        assert_empty(combinations)
      end

      test "#generate_combinations contains address1, address2" do
        address1 = "123 Main St"
        address2 = "Apt 1"
        @address_parser_preprocessor = AddressParserPreprocessor.new(
          address: build_address(country_code: :ca, address1: address1, address2: address2),
        )
        combinations = @address_parser_preprocessor.generate_combinations
        assert(combinations.include?(address1))
        assert(combinations.include?(address2))
      end

      test "#generate_combinations contains combined address1 and address2" do
        address1 = "123 Main St"
        address2 = "Apt 1"
        @address_parser_preprocessor = AddressParserPreprocessor.new(
          address: build_address(country_code: :ca, address1: address1, address2: address2),
        )
        combined_address = "#{address1} #{address2}"
        combinations = @address_parser_preprocessor.generate_combinations
        assert(combinations.include?(combined_address))
      end

      test "#generate_combinations contain only unique values" do
        address1 = "123 Main St"
        address2 = nil
        @address_parser_preprocessor = AddressParserPreprocessor.new(
          address: build_address(country_code: :ca, address1: address1, address2: address2),
        )
        combinations = @address_parser_preprocessor.generate_combinations
        assert_equal(1, combinations.length)
      end

      test "#generate_combinations includes address1 stripped of known address components " \
        "(address2, city, province, country)" do
        Worldwide::Region.any_instance.stubs(:name_alternates).returns(["USA"])

        [
          [
            # comma separated with codes
            build_address(
              address1: "2753 Greenway Drive, Frisco, TX, US",
              address2: nil,
              city: "Frisco",
              province_code: "TX",
              country_code: :us,
            ),
            ["2753 Greenway Drive"],
          ],
          [
            # comma separated with names
            build_address(
              address1: "2753 Greenway Drive, Frisco, Texas, United States",
              address2: nil,
              city: "Frisco",
              province_code: "TX",
              country_code: :us,
            ),
            ["2753 Greenway Drive"],
          ],
          [
            # Alternate Country Name
            build_address(
              address1: "2753 Greenway Drive, Frisco, TX, USA",
              address2: nil,
              city: "Frisco",
              province_code: "TX",
              country_code: :us,
            ),
            ["2753 Greenway Drive"],
          ],
          [
            # no commas
            build_address(
              address1: "2753 Greenway Drive Frisco Texas United States",
              address2: nil,
              city: "Frisco",
              province_code: "TX",
              country_code: :us,
            ),
            ["2753 Greenway Drive"],
          ],
          [
            # with address2
            build_address(
              address1: "2753 Greenway Drive, Apt 2, Frisco, TX, US",
              address2: "Apt 2",
              city: "Frisco",
              province_code: "TX",
              country_code: :us,
            ),
            ["2753 Greenway Drive"],
          ],
          [
            # with valid zip, ensure we have both versions retained
            build_address(
              address1: "8124 N 33Dr Drive Unit 1 Phoenix Arizona 85051",
              address2: "",
              city: "Phoenix",
              zip: "85051",
              province_code: "AZ",
              country_code: :us,
            ),
            ["8124 N 33Dr Drive Unit 1 85051", "8124 N 33Dr Drive Unit 1"],
          ],
        ].each do |address, expected|
          @address_parser_preprocessor = AddressParserPreprocessor.new(
            address: address,
          )
          combinations = @address_parser_preprocessor.generate_combinations
          assert(expected.to_set.subset?(combinations.to_set), "Expected #{expected} to be in #{combinations}")
        end
      end

      test "#generate_combinations does not remove zip if the zip is invalid" do
        address = build_address(
          address1: "175 Little River 705, Ashdown, AR",
          address2: nil,
          city: "Ashdown",
          zip: "705", # invalid zip
          province_code: "AR",
          country_code: :us,
        )
        @address_parser_preprocessor = AddressParserPreprocessor.new(
          address: address,
        )
        combinations = @address_parser_preprocessor.generate_combinations
        assert(combinations.include?("175 Little River 705"))
      end

      test "#generate_combinations includes address1 sliced on the street suffix or directional" do
        addresses = [
          { address1: "123 5th Avenue care of John Smith", sliced_address1: "123 5th Avenue" },
          { address1: "123 St Paul St care of John Smith", sliced_address1: "123 St Paul St" },
          { address1: "123 Main St E", sliced_address1: "123 Main St E" },
          { address1: "123 Main St west", sliced_address1: "123 Main St west" },
          { address1: "123 Main St Unit 5", sliced_address1: "123 Main St" },
        ]

        addresses.each do |address|
          @address_parser_preprocessor = AddressParserPreprocessor.new(
            address: build_address(country_code: :us, address1: address[:address1], address2: nil),
          )
          combinations = @address_parser_preprocessor.generate_combinations
          assert(combinations.include?(address[:sliced_address1]))
        end
      end
    end
  end
end
