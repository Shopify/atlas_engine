# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      module Validators
        class FullAddressStreet < FullAddress
          sig { params(address: TAddress, result: Result).void }
          def initialize(address:, result: Result.new)
            super
            @session = T.let(Session.new(address: address, matching_strategy: MatchingStrategies::EsStreet), Session)
          end
        end
      end
    end
  end
end
