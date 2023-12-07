# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module Validation
      module Validator
        extend T::Sig
        extend T::Helpers
        interface!

        sig { abstract.params(address: T.untyped).returns(T::Boolean) }
        def valid?(address); end
      end
    end
  end
end
