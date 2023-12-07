# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class CacheTest < ActiveSupport::TestCase
          test "country caches country" do
            region = Worldwide::Region.new(iso_code: "xx")
            Worldwide.expects(:region).with(code: "xx").times(1).returns(region)

            cache = Cache.new(AddressValidation::Address.new(country_code: "xx"))
            10.times { cache.country }
          end

          test "country returns empty region when country_code is not present in address" do
            cache = Cache.new(AddressValidation::Address.new)
            assert_equal "ZZ", cache.country.iso_code
          end

          test "province caches province" do
            region = Worldwide::Region.new(iso_code: "xx")
            province = Worldwide::Region.new(iso_code: "zz")

            Worldwide.expects(:region).with(code: "xx").times(1).returns(region)
            region.expects(:zone).with(code: "zz").times(1).returns(province)

            cache = Cache.new(AddressValidation::Address.new(country_code: "xx", province_code: "zz"))
            10.times { cache.province }
          end

          test "province returns empty region when province_code is not present in address" do
            cache = Cache.new(AddressValidation::Address.new(country_code: "us"))
            assert_equal "US", cache.country.iso_code
            assert_equal "ZZ", cache.province.iso_code
          end
        end
      end
    end
  end
end
