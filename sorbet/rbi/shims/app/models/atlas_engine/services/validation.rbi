# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Services
    class Validation
      class << self
        sig { params(address: AddressValidation::AbstractAddress).returns(T::Boolean) }
        def validation_enabled?(address); end
      end
    end
  end
end
