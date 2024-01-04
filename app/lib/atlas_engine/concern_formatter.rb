# typed: true
# frozen_string_literal: true

module AtlasEngine
  module ConcernFormatter
    include Kernel # https://github.com/sorbet/sorbet/issues/1109
    extend T::Sig

    sig { returns(AddressValidation::AbstractAddress) }
    def address
      raise NotImplementedError
    end

    sig { returns(String) }
    def country_name
      return "" if address.country_code.blank?

      country.country? && country.full_name ? country.full_name : address.country_code
    end

    sig { returns(String) }
    def province_name
      return "" if address.country_code.blank? || address.province_code.blank?

      province.province? && province.full_name ? province.full_name : address.province_code
    end

    private

    sig { returns(Worldwide::Region) }
    def country
      @country ||= Worldwide.region(code: address.country_code)
    end

    sig { returns(Worldwide::Region) }
    def province
      @province ||= country.zone(code: address.province_code)
    end
  end
end
