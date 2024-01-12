# typed: false
# frozen_string_literal: true

module AtlasEngine
  class PostAddress < ApplicationRecord
    extend T::Sig

    validates :country_code, :city, presence: true
    validate :country_must_be_supported, :province_must_match_country, :zip_must_match_country_and_province
    serialize :city, type: Array, coder: YAML

    sig { returns(T::Hash[Symbol, T.untyped]) }
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

    private

    sig { void }
    def country_must_be_supported
      if country_code.blank?
        errors.add(:country, "is required")
      elsif !country.country?
        errors.add(:country, "with code '#{country_code}' is not recognized") unless country.country?
      end
    end

    sig { void }
    def province_must_match_country
      return if country_code.blank?
      return unless country_has_provinces?

      if province_missing?
        errors.add(:province_code, "is required for country '#{country_code}'") if province_missing?
      elsif province_invalid?
        errors.add(:province_code, "'#{province_code}' is invalid for country '#{country_code}'")
      end
    end

    sig { void }
    def zip_must_match_country_and_province
      return if country_code.blank?

      zip_must_match_country
      return if errors[:zip].any?

      zip_must_match_province
    end

    sig { void }
    def zip_must_match_country
      return unless country_has_zip_codes?

      if zip.blank? && country.zip_required?
        errors.add(:zip, "is required for country '#{country_code}'")
      elsif !country.valid_zip?(zip)
        errors.add(:zip, "'#{zip}' is invalid for country '#{country_code}'")
      end
    end

    sig { void }
    def zip_must_match_province
      return unless province_code

      province = country.zone(code: province_code)

      return unless province.province?
      return if province.valid_zip?(zip)

      errors.add(:zip, "'#{zip}' is invalid for province '#{province_code}'")
    end

    sig { returns(Worldwide::Region) }
    def country
      @country ||= T.let(Worldwide.region(code: country_code), T.nilable(Worldwide::Region))
    end

    sig { returns(T::Boolean) }
    def country_has_provinces?
      country.zones.present? && !country.hide_provinces_from_addresses
    end

    sig { returns(T::Boolean) }
    def country_has_zip_codes?
      country.country? && country.has_zip?
    end

    sig { returns(T::Boolean) }
    def province_invalid?
      province_code.present? && !country.zone(code: province_code).province?
    end

    sig { returns(T::Boolean) }
    def province_missing?
      province_code.blank? && !country.province_optional?
    end
  end
end
