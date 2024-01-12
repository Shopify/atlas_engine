# typed: false
# frozen_string_literal: true

require "csv"

module AtlasEngine
  class PostAddressImporter
    def initialize(file)
      @file = file
    end

    def import
      CSV.foreach(@file, headers: true) do |row|
        PostAddress.create!(
          source_id: row["source_id"],
          locale: row["locale"],
          country_code: row["country_code"],
          province_code: row["province_code"],
          region1: row["region1"],
          region2: row["region2"],
          region3: row["region3"],
          region4: row["region4"],
          city: row["city"],
          suburb: row["suburb"],
          zip: row["zip"],
          street: row["street"],
          building_name: row["building_name"],
          latitude: row["latitude"],
          longitude: row["longitude"],
        )
      end
    end
  end
end
