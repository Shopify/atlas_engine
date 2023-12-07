# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    module Corrections
      class CorrectorTest < ActiveSupport::TestCase
        test "#apply invokes #apply on the instance's correctors" do
          address = FactoryBot.attributes_for(:post_address)
          corrector = Corrector.new(country_code: "FR", source: "open_address")
          expected_corrector = AtlasEngine::Fr::AddressImporter::Corrections::OpenAddress::CityCorrector

          assert_equal [expected_corrector], corrector.correctors
          expected_corrector.expects(:apply).once.with(address)

          corrector.apply(address)
        end

        test ".new finds data with lowercase country code" do
          corrector = Corrector.new(country_code: "fr", source: "open_address")
          expected_corrector = AtlasEngine::Fr::AddressImporter::Corrections::OpenAddress::CityCorrector

          assert_equal [expected_corrector], corrector.correctors
        end
      end
    end
  end
end
