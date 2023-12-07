# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    module OpenAddress
      class LoaderTest < ActiveSupport::TestCase
        test "#load will upsert_all addresses and join on building_and_unit_ranges" do
          address1 = {
            "id" => "123",
            "source_id" => "123",
            "country_code" => "ZZ",
            "locale" => "en",
            "province_code" => nil,
            "region1" => "Region",
            "city" => ["City"],
            "suburb" => nil,
            "zip" => "12345",
            "street" => "Street",
            "building_and_unit_ranges" => ["1-2"],
          }
          address2 = address1.dup.merge("building_and_unit_ranges" => ["3-6"])

          loader = Loader.new
          loader.load([address1, address2])

          assert_equal 1, PostAddress.count
          assert_equal "123", PostAddress.first.source_id
          assert_equal ["1-2", "3-6"], PostAddress.first.building_and_unit_ranges
        end
      end
    end
  end
end
