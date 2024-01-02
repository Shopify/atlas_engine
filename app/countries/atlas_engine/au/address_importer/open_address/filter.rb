# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Au
    module AddressImporter
      module OpenAddress
        class Filter
          extend T::Sig
          include AtlasEngine::AddressImporter::OpenAddress::Filter

          def initialize(country_import:); end

          sig { override.params(feature: AtlasEngine::AddressImporter::OpenAddress::Feature).returns(T::Boolean) }
          def filter(feature)
            # Discard features from the overseas territories, like Cocos, Christmas Island, etc.
            # See: https://github.com/Shopify/worldwide/blob/c76c344/db/data/world.yml#L304-L308
            return false if feature["region"] == "OT"

            true
          end
        end
      end
    end
  end
end
