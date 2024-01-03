# typed: true
# frozen_string_literal: true

# This class is responsible for checking whether the session postal code is a valid partial length.
# If valid, #truncate will return a truncated candidate postal code that corresponds to a valid partial range.
# Else, #truncate will return the unmodified candidate postal code.

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class PostalCodeMatcher
          extend T::Sig
          include LogHelper

          attr_reader :country_code, :session_postal_code, :candidate_postal_code

          sig do
            params(country_code: String, session_postal_code: String, candidate_postal_code: T.nilable(String)).void
          end
          def initialize(country_code, session_postal_code, candidate_postal_code = nil)
            @country_code = country_code
            @session_postal_code = session_postal_code
            @candidate_postal_code = candidate_postal_code
          end

          sig { returns(T.nilable(String)) }
          def truncate
            return unless candidate_postal_code
            return candidate_postal_code if candidate_postal_code.size <= session_postal_code.size
            return candidate_postal_code unless valid_partial_postal_code_length?

            truncated_postal_code = candidate_postal_code[partial_postal_code_range]

            log_info("Truncating candidate postal code", {
              session_postal_code: session_postal_code,
              original_postal_code: candidate_postal_code,
              truncated_postal_code: truncated_postal_code,
            })

            truncated_postal_code
          end

          private

          sig { returns(T::Boolean) }
          def valid_partial_postal_code_length?
            partial_postal_code_range.present?
          end

          sig { returns(T.nilable(Range)) }
          def partial_postal_code_range
            @partial_postal_code_range ||= CountryProfile.for(country_code)
              .validation.partial_postal_code_range(session_postal_code.size)
          end
        end
      end
    end
  end
end
