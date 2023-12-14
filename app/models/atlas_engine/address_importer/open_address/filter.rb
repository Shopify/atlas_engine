# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module OpenAddress
      module Filter
        extend T::Sig
        extend T::Helpers
        interface!

        sig { abstract.params(feature: T::Hash[String, T.untyped]).returns(T::Boolean) }
        def filter(feature); end
      end
    end
  end
end
