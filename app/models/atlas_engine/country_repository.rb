# # typed: strict
# # frozen_string_literal: true

module AtlasEngine
  class CountryRepository
    include LogHelper

    PostAddressData = T.type_alias { T.any(PostAddress, T::Hash[Symbol, T.untyped]) }
  end
end
