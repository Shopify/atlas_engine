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

                sig { params(address: AtlasEngine::AddressValidation::AbstractAddress).returns(T::Boolean) }
                def apply?(address)
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
