# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    class SessionTest < ActiveSupport::TestCase
      include AddressValidation::AddressValidationTestHelper
      include AddressValidation::TokenHelper

      test "exposes address input fields" do
        session = AddressValidation::Session.new(address: address)
        assert_equal "123 Main Street", session.address1
        assert_equal "Entrance B", session.address2
        assert_equal "Springfield", session.city
        assert_equal "ME", session.province_code
        assert_equal "US", session.country_code
        assert_equal "04487", session.zip
        assert_equal "1234567890", session.phone
      end

      test "parsings returns the correct parsings" do
        session = AddressValidation::Session.new(address: address)
        assert_equal [{ building_num: "123", street: "Main Street" }], session.parsings.parsings
      end

      test "datastore returns the correct datastore" do
        session = AddressValidation::Session.new(address: address)

        assert_equal AtlasEngine::AddressValidation::Es::Datastore, session.datastore.class
        assert_equal 1, session.datastore_hash.size
      end

      test "datastore caches by locale" do
        session = AddressValidation::Session.new(address: address_ch)
        assert_equal AtlasEngine::AddressValidation::Es::Datastore, session.datastore(locale: "it").class
        assert_equal 1, session.datastore_hash.size

        session.datastore(locale: "it")
        assert_equal 1, session.datastore_hash.size

        AddressValidation::Session.new(address: address_ch)
        assert_equal AtlasEngine::AddressValidation::Es::Datastore, session.datastore(locale: "fr").class
        assert_equal 2, session.datastore_hash.size
      end

      private

      def address
        build_address(
          address1: "123 Main Street",
          address2: "Entrance B",
          city: "Springfield",
          province_code: "ME",
          country_code: "US",
          zip: "04487",
          phone: "1234567890",
        )
      end

      def address_ch
        build_address(
          address1: "Vordere Gasse 7",
          address2: "",
          city: "Busslingen",
          province_code: "",
          country_code: "CH",
          zip: "5453",
          phone: "1234567890",
        )
      end
    end
  end
end
