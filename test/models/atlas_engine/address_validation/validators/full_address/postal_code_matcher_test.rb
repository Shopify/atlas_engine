# typed: false
# frozen_string_literal: true

require "test_helper"
require "helpers/atlas_engine/log_assertion_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class PostalCodeMatcherTest < ActiveSupport::TestCase
          include LogAssertionHelper

          test "#truncate returns a partial postal code when the session postal code length is valid" do
            candidate_postal_code = "S2918 BNA"
            four_char_session_postal_code = "2919"
            five_char_session_postal_code = "S2919"

            assert_log_append(
              :info,
              "AtlasEngine::AddressValidation::Validators::FullAddress::PostalCodeMatcher",
              "Truncating candidate postal code",
              {
                session_postal_code: four_char_session_postal_code,
                original_postal_code: candidate_postal_code,
                truncated_postal_code: "2918",
              },
            )

            assert_log_append(
              :info,
              "AtlasEngine::AddressValidation::Validators::FullAddress::PostalCodeMatcher",
              "Truncating candidate postal code",
              {
                session_postal_code: five_char_session_postal_code,
                original_postal_code: candidate_postal_code,
                truncated_postal_code: "S2918",
              },
            )

            assert_equal "2918",
              PostalCodeMatcher.new("AR", four_char_session_postal_code, candidate_postal_code).truncate
            assert_equal "S2918",
              PostalCodeMatcher.new("AR", five_char_session_postal_code, candidate_postal_code).truncate
          end

          test "#truncate returns nil when the candidate postal code is not defined" do
            session_postal_code = "S2919"

            matcher = PostalCodeMatcher.new("AR", session_postal_code)
            assert_nil matcher.truncate
          end

          test "#truncate returns the original candidate postal code when the session postal code length is greater than the candidate length" do
            candidate_postal_code = "2919" # 4 chars
            session_postal_code = "S2919" # 5 chars

            matcher = PostalCodeMatcher.new("AR", session_postal_code, candidate_postal_code)
            assert_equal candidate_postal_code, matcher.truncate
          end

          test "#truncate returns the original candidate postal code when the session postal code is not a valid length" do
            candidate_postal_code = "S2919 BNA"

            matcher = PostalCodeMatcher.new("AR", "S2919 B", candidate_postal_code)
            assert_equal candidate_postal_code, matcher.truncate
          end

          test "#truncate returns the original candidate postal when no partial postal code range is defined" do
            candidate_postal_code = "123456"

            matcher = PostalCodeMatcher.new("CA", "ABCD", candidate_postal_code)
            assert_equal candidate_postal_code, matcher.truncate
          end
        end
      end
    end
  end
end
