# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class ProvinceCodeNormalizer
      class << self
        extend T::Sig
        sig { params(country_code: T.nilable(String), province_code: T.nilable(String)).returns(T.nilable(String)) }
        def normalize(country_code:, province_code:)
          return if province_code.blank?
          return province_code if country_code.blank?

          iso_code(country_code, province_code) ||
            iso_from_cldr(country_code, province_code) ||
            province_code
        end

        private

        sig { params(country_code: String, province_code: String).returns(T.nilable(String)) }
        def iso_code(country_code, province_code)
          zone = Worldwide.region(code: country_code)&.zone(code: province_code)
          zone.province? ? zone.iso_code : nil
        end

        sig { params(country_code: String, province_code: String).returns(T.nilable(String)) }
        def iso_from_cldr(country_code, province_code)
          zone = Worldwide.region(code: province_code)
          if zone_valid?(zone, country_code)
            return zone.iso_code
          end

          zone = Worldwide.region(cldr: province_code)
          zone_valid?(zone, country_code) ? zone.iso_code : nil
        end

        sig { params(zone: Worldwide::Region, country_code: String).returns(T::Boolean) }
        def zone_valid?(zone, country_code)
          zone.province? && zone.associated_country.iso_code.casecmp(country_code) == 0
        end
      end
    end
  end
end
