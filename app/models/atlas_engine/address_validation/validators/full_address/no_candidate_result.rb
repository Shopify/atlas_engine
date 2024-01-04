# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class NoCandidateResult < CandidateResultBase
          extend T::Sig

          sig { void }
          def update_result
            result.concerns << UnknownAddressConcern.new(
              address,
            )

            concern = InvalidZipConcernBuilder.for(session.address, [])
            result.concerns << concern if concern

            update_result_scope
          end
        end
      end
    end
  end
end