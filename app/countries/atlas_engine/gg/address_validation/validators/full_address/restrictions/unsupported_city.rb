# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Gg
    module AddressValidation
      module Validators
        module FullAddress
          module Restrictions
            class UnsupportedCity              
              UNSUPPORTED_CITIES = [
                "SARK",
                "ALDERNEY",
              ].freeze

              class << self
                extend T::Sig

                sig { params(address: AtlasEngine::AddressValidation::AbstractAddress).returns(T::Boolean) }
                def apply?(address)
                  address.city&.upcase&.in?(UNSUPPORTED_CITIES)
                end
              end
            end
          end
        end
      end
    end
  end
end
