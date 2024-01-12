# typed: false
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Request < T::Struct
      const :address, AbstractAddress
      const :locale, String, default: "en"
      const :matching_strategy, T.nilable(T.any(String, Symbol)), default: nil
    end
  end
end
