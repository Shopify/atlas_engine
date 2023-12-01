# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Types
    class ValidationSupportedCountry < BaseEnum
      Worldwide::Regions.all.select(&:country?).reject(&:deprecated?).map do |country|
        value country.iso_code, description: country.full_name
      end
    end
  end
end
