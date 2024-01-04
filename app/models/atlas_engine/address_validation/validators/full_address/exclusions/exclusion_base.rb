# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        module Exclusions
          class ExclusionBase
            class << self
              extend T::Sig
              extend T::Helpers
              abstract!

              sig { abstract.params(session: Session, candidate: Candidate).returns(T::Boolean) }
              def apply?(session, candidate); end
            end
          end
        end
      end
    end
  end
end
