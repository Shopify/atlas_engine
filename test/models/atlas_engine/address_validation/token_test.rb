# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    class TokenTest < ActiveSupport::TestCase
      include AddressValidation::TokenHelper

      test ".from_term_vector creates token" do
        field_terms = {
          "terms" => {
            "alfredo" => {
              "term_freq" => 1,
              "tokens" => [
                {
                  "position" => 1,
                  "start_offset" => 6,
                  "end_offset" => 13,
                },
              ],
            },
            "calle" => {
              "term_freq" => 1,
              "tokens" => [
                {
                  "position" => 0,
                  "start_offset" => 0,
                  "end_offset" => 5,
                },
              ],
            },
          },
        }

        returned_terms = AddressValidation::Token.from_field_term_vector(field_terms).map(&:instance_values)
        expected_hash = [
          {
            "value" => "calle",
            "start_offset" => 0,
            "end_offset" => 5,
            "type" => nil,
            "position" => 0,
            "position_length" => 1,
          },
          {
            "value" => "alfredo",
            "start_offset" => 6,
            "end_offset" => 13,
            "type" => nil,
            "position" => 1,
            "position_length" => 1,
          },
        ]

        assert_equal expected_hash, returned_terms
      end

      test ".from_analyze creates token" do
        token_hash = {
          "token" => "test",
          "start_offset" => 0,
          "end_offset" => 3,
          "type" => "SYNONYM",
          "position" => 0,
          "positionLength" => 2,
        }

        returned_terms = AddressValidation::Token.from_analyze(token_hash).instance_values
        expected_hash = {
          "value" => "test",
          "start_offset" => 0,
          "end_offset" => 3,
          "type" => "SYNONYM",
          "position" => 0,
          "position_length" => 2,
        }

        assert_equal expected_hash, returned_terms
      end

      test ".from_analyze defaults to position_length: 1" do
        token_hash = {
          "token" => "test",
          "start_offset" => 0,
          "end_offset" => 3,
          "type" => "SYNONYM",
          "position" => 0,
        }

        returned_terms = AddressValidation::Token.from_analyze(token_hash).instance_values
        expected_hash = {
          "value" => "test",
          "start_offset" => 0,
          "end_offset" => 3,
          "type" => "SYNONYM",
          "position" => 0,
          "position_length" => 1,
        }

        assert_equal expected_hash, returned_terms
      end

      test "#inspect" do
        token = token(value: "A", start_offset: 1, end_offset: 2, type: "<ALPHANUM>", position: 3)
        assert_match %r{<tok id:\d{4} val:"A" strt:1 end:2 pos:3 type:<ALPHANUM>/>}, token.inspect
      end

      test "#inspect returns position length if position length is greater than 1" do
        token = token(value: "A", start_offset: 1, end_offset: 2, type: "<ALPHANUM>", position: 3, position_length: 2)
        assert_match %r{<tok id:\d{4} val:"A" strt:1 end:2 pos:3 type:<ALPHANUM> pos_length:2/>}, token.inspect
      end

      test "#inspect_short" do
        token = token(value: "A", start_offset: 1, end_offset: 2, type: "<ALPHANUM>", position: 3)
        assert_match(/<tok id:\d{4} val:"A"/, token.inspect)
      end

      test "#offset_range returns range from start_offset (inclusive) to end_offset (exclusive)" do
        token = token(value: "A", start_offset: 1, end_offset: 2, type: "<ALPHANUM>", position: 3)
        assert_equal 1...2, token.offset_range
      end

      test "#preceeds returns true if token's position immediately preceeds other token's position" do
        token = token(value: "A", start_offset: 1, end_offset: 2, type: "<ALPHANUM>", position: 0)
        other_token = token(value: "B", start_offset: 1, end_offset: 2, type: "<ALPHANUM>", position: 1)

        assert token.preceeds?(other_token)
      end

      test "#preceeds returns false if token's position does not immediately preceed other token's position" do
        token = token(value: "A", position: 0)
        other_token = token(value: "B", position: 2)

        assert_not token.preceeds?(other_token)
      end

      test "#preceeds returns false if token's position is greater than other token's position" do
        token = token(value: "A", position: 1)
        other_token = token(value: "B", position: 0)

        assert_not token.preceeds?(other_token)
      end
    end
  end
end
