# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      module DataMappers
        class DefaultDataMapper
          extend T::Sig
          include LogHelper

          sig { returns(CountryRepository::PostAddressData) }
          attr_reader :post_address

          sig { returns(String) }
          attr_reader :locale

          sig do
            params(
              post_address: CountryRepository::PostAddressData,
              country_profile: CountryProfile,
              locale: String,
            ).void
          end
          def initialize(post_address:, country_profile:, locale: "")
            @post_address = post_address
            @country_profile = country_profile
            @locale = T.let((locale.empty? ? post_address[:locale] : locale), String)
          end

          sig do
            returns(T::Hash[Symbol, T.untyped])
          end
          def map_data
            {}.tap do |data|
              data.update(
                post_address
                  .slice(:id, :locale, :country_code, :province_code, :region1, :region2, :region3, :region4)
                  .deep_symbolize_keys,
              )
              data[:city_aliases] = city_aliases(post_address[:city])
              data[:suburb] = post_address[:suburb]
              data[:zip] = Worldwide::Zip.normalize(
                country_code: post_address[:country_code],
                zip: post_address[:zip],
              )
              data[:street] = post_address[:street]
              data[:street_stripped] = street_stripped(post_address[:street])
              data[:street_decompounded] = nil
              data[:building_and_unit_ranges] = JSON.generate(post_address[:building_and_unit_ranges])
              data[:approx_building_ranges] = approx_building_ranges(post_address[:building_and_unit_ranges]&.keys)
              data.update(
                post_address.slice(:building_name, :latitude, :longitude).deep_symbolize_keys,
              )
              data[:location] = {
                lat: post_address[:latitude],
                lon: post_address[:longitude],
              }
            end
          end

          protected

          sig { returns(CountryProfile) }
          attr_reader :country_profile

          sig { params(cities: T::Array[String]).returns(T::Array[T::Hash[Symbol, String]]) }
          def city_aliases(cities)
            cities.map do |city|
              {
                alias: city,
              }
            end
          end

          sig { params(street: T.nilable(String)).returns(T.nilable(String)) }
          def street_stripped(street)
            return if street.blank?

            Street.new(street: street).with_stripped_name
          end

          sig { params(ranges: T.nilable(T::Array[String])).returns(T.nilable(T::Array[T::Hash[String, Integer]])) }
          def approx_building_ranges(ranges)
            return unless ranges

            numeric_ranges = ranges.filter_map do |range_str|
              AddressNumberRange.new(range_string: range_str).approx_numeric_range
            end
            merged_ranges = AddressNumberRange.merge_overlapping_ranges(numeric_ranges)
            merged_ranges.map { |range| es_integer_range(min: range.min, max: range.max) }
          rescue AddressNumberRange::RangeError => e
            log_warn("[#{e.class}]: #{e.message}")
            nil
          end

          sig { params(min: Integer, max: Integer).returns(T::Hash[String, Integer]) }
          def es_integer_range(min:, max:)
            { "gte" => min, "lte" => max }
          end

          sig { returns(String) }
          def locale_language_code
            Worldwide.locale(code: locale).language_subtag
          end
        end
      end
    end
  end
end
