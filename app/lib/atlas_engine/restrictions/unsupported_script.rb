# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Restrictions
    class UnsupportedScript
      class << self
        extend T::Sig
        include Base

        sig do
          override(allow_incompatible: true).params(address: AtlasEngine::AddressValidation::AbstractAddress, supported_script: Symbol).returns(T::Boolean)
        end
        def apply?(address:, supported_script:)
          scripts = Worldwide.scripts.identify(
            text: address.address1.to_s + ' ' + address.address2.to_s + ' ' + address.city.to_s
          )
          return false if scripts.empty?

          scripts.any? { |script| script != supported_script }
        end
      end
    end
  end
end
