# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Kr
    module AddressValidation
      module Validators
        module FullAddress
          module Restrictions
            class UnsupportedScript
              # OpenAddress only provides address data in Hangul script. Addresses in other scripts cannot be validated.
              class << self
                extend T::Sig

                sig { params(address: AtlasEngine::AddressValidation::AbstractAddress).returns(T::Boolean) }
                def apply?(address)
                  scripts = Worldwide.scripts.identify(
                    text: address.address1.to_s + ' ' + address.address2.to_s + ' ' + address.city.to_s
                  )
                  return false if scripts.empty?

                  scripts.any? { |script| script != :Hangul }
                end
              end
            end
          end
        end
      end
    end
  end
end
