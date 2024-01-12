# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Gg
    module AddressValidation
      module Validators
        module FullAddress
          module Restrictions
            class UnsupportedCity
              UNSUPPORTED_CITY_ZIP_MAPPING = {
                "SARK" => "GY9",
                "ALDERNEY" => "GY10",
              }.freeze

              class << self
                extend T::Sig
                include AtlasEngine::Restrictions::Base

                sig do
                  override.params(
                    address: AtlasEngine::AddressValidation::AbstractAddress,
                    params: T.untyped,
                  ).returns(T::Boolean)
                end
                def apply?(address:, params: nil)
                  zip_prefix = UNSUPPORTED_CITY_ZIP_MAPPING[address.city&.upcase]
                  return false if zip_prefix.nil?

                  address.zip&.start_with?(zip_prefix).present?
                end
              end
            end
          end
        end
      end
    end
  end
end
