# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    class NormalizerTest < ActiveSupport::TestCase
      class TestNormalizer
        extend Normalizer
      end

      test "#normalize returns a normalized address" do
        arabic_city_strings = {
          "الطائف" => "الطايف",
          "قرية" => "قريه",
          "رحــــــيم" => "رحيم",
        }

        arabic_city_strings.each do |city_string, expected_normalized_string|
          assert_equal expected_normalized_string, TestNormalizer.normalize(city_string)
        end
      end
    end
  end
end
