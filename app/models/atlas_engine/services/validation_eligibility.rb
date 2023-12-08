# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Services
    module ValidationEligibility
      extend T::Sig

      sig { params(address: AddressValidation::AbstractAddress).returns(T::Boolean) }
      def validation_enabled?(address)
        return false if address.country_code.blank?
        return true unless Rails.env.production? || Rails.env.test?

        CountryProfile.for(T.must(address.country_code)).validation.enabled
      end
    end
  end
end
