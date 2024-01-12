# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Restrictions
    class UnsupportedScript
      class << self
        extend T::Sig
        include Base

        sig do
          override.params(
            address: AtlasEngine::AddressValidation::AbstractAddress,
            params: T.untyped,
          ).returns(T::Boolean)
        end
        def apply?(address:, params: {})
          supported_script = params[:supported_script]
          return false if supported_script.nil?

          scripts = Worldwide.scripts.identify(
            text: address.address1.to_s + " " + address.address2.to_s + " " + address.city.to_s,
          )
          return false if scripts.empty?

          scripts.any? { |script| script != supported_script }
        end
      end
    end
  end
end
