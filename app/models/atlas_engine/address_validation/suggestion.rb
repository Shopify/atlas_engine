# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Suggestion
      extend T::Sig

      sig { returns(T.nilable(String)) }
      attr_reader :id

      sig { returns(T.nilable(String)) }
      attr_accessor :address1

      sig { returns(T.nilable(String)) }
      attr_accessor :address2

      sig { returns(T.nilable(String)) }
      attr_accessor :city

      sig { returns(T.nilable(String)) }
      attr_accessor :zip

      sig { params(province_code: T.nilable(String)).returns(T.nilable(String)) }
      attr_writer :province_code

      sig { returns(T.nilable(String)) }
      attr_accessor :country_code

      sig do
        params(
          address1: T.nilable(String),
          address2: T.nilable(String),
          city: T.nilable(String),
          zip: T.nilable(String),
          province_code: T.nilable(String),
          country_code: T.nilable(String),
        ).void
      end
      def initialize(address1: nil, address2: nil, city: nil, zip: nil, province_code: nil, country_code: nil)
        @address1 = address1
        @address2 = address2
        @city = city
        @zip = zip
        @province_code = province_code
        @original_country_code = country_code
        @country_code = country_code

        # generate_id uses the values of the attributes to calculate the UUID, so must be called after they're set
        @id = T.let(generate_id, String)
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def attributes
        {
          id: id,
          address1: address1,
          address2: address2,
          city: city,
          zip: zip,
          province_code: province_code,
          province: province,
          country_code: country_code,
        }
      end

      sig { returns(T.nilable(String)) }
      def province
        return if @original_country_code.nil? || @province_code.nil?

        province = Worldwide.region(code: @original_country_code)&.zone(code: @province_code)
        province.province? ? province.full_name : nil
      end

      sig { returns(T.nilable(String)) }
      def province_code
        return @province_code if @province_code.blank?

        # This hack is required since checkout-web is using province codes differently for Japan Vs Other countries
        # Japan province codes are expected as full ISO codes (JP-14)
        # while other countries are expected as 2 digit subdivision codes (e.g. ON)
        # we can remove this logic if the client can accept 2 digit subdivision codes / ISO codes as standard response
        province = Worldwide.region(code: @original_country_code)&.zone(code: @province_code)
        return @province_code unless province.province?

        province.legacy_code
      end

      private

      sig { returns(String) }
      def generate_id
        Digest::UUID.uuid_v5(Digest::UUID::OID_NAMESPACE, attributes.except(:id).to_s)
      end
    end
  end
end
