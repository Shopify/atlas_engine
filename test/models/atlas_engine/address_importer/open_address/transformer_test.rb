# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    module OpenAddress
      class TransformerTest < ActiveSupport::TestCase
        class RegularCorrector
          def apply(address)
            address[:street] = "corrected_value!"
          end
        end

        class ClearingCorrector
          def apply(address)
            address.clear
          end
        end

        setup do
          @country_import = CountryImport.create(country_code: "DK")
          @feature = {
            "type" => "Feature",
            "properties" =>
           {
             "hash" => "9ac45faa4a783dbf",
             "number" => "13",
             "street" => "Isefjords Alle",
             "unit" => "11 3",
             "city" => "Holbæk",
             "district" => "",
             "region" => "Region Sjælland",
             "postcode" => "4300",
             "id" => "",
           },
            "geometry" => { "type" => "Point", "coordinates" => [11.7165786, 55.7202219] },
          }
          @klass = Transformer.new(country_import: @country_import)
        end

        test "#transform returns a hash with the expected keys" do
          expected = {
            source_id: "OA#9ac45faa4a783dbf",
            locale: nil,
            country_code: "DK",
            province_code: nil,
            region1: "Region Sjælland",
            city: ["Holbæk"],
            suburb: nil,
            zip: "4300",
            street: "Isefjords Alle",
            longitude: 11.7165786,
            latitude: 55.7202219,
            building_and_unit_ranges: { "13" => { "11 3" => {} } },
          }

          result = @klass.transform(@feature)

          assert_equal(expected, result)
        end

        test "#transform returns transformed and corrected address hash when country has correctors and address is valid" do
          corrector = RegularCorrector.new
          AddressImporter::Corrections::Corrector.any_instance.expects(:correctors).returns([corrector])
          AddressImporter::Validation::Wrapper.any_instance.expects(:valid?).returns(true)

          corrected_street = "corrected_value!"
          assert_equal corrected_street, @klass.transform(@feature)[:street]
        end

        test "#transform returns nil when corrector voids the address" do
          corrector = ClearingCorrector.new
          AddressImporter::Corrections::Corrector.any_instance.expects(:correctors).returns([corrector])

          assert_nil @klass.transform(@feature)
        end

        test "#transform returns nil when address is not valid" do
          AddressImporter::Corrections::Corrector.any_instance.expects(:correctors).returns([])
          AddressImporter::Validation::Wrapper.any_instance.expects(:valid?).returns(false)

          assert_nil @klass.transform(@feature)
        end

        test "#transform uses the passed in locale" do
          locale = "da"
          transformer = Transformer.new(country_import: @country_import, locale: locale)

          result = transformer.transform(@feature)

          assert_equal(locale, result[:locale])
        end
      end
    end
  end
end
