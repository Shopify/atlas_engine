module AtlasEngine
  class PostAddress < ApplicationRecord
    def to_h
      {
        source_id: source_id,
        locale: locale,
        country_code: country_code,
        province_code: province_code,
        region1: region1,
        region2: region2,
        region3: region3,
        region4: region4,
        city: city,
        suburb: suburb,
        zip: zip,
        street: street,
        building_name: building_name,
        latitude: latitude,
        longitude: longitude,
      }.compact
    end
  end
end
