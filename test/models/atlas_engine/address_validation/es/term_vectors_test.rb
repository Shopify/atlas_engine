# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Es
      class TermVectorsTest < ActiveSupport::TestCase
        include AddressValidation::TokenHelper

        test "#set_candidate_sequences sets sequences for single value components" do
          candidates = [candidate("1"), candidate("2", { street: "Elm Street" })]
          term_vectors = TermVectors.new(term_vectors_hashes: term_vectors_single_value, candidates: candidates)
          term_vectors.set_candidate_sequences

          expected_city_sequences = [Token::Sequence.new(
            tokens: [
              Token.new(
                value: "foo",
                start_offset: 0,
                end_offset: 3,
                position: 0,
              ),
            ],
          )]
          expected_street_sequences1 = [Token::Sequence.new(tokens: [
            Token.new(
              value: "bar",
              start_offset: 0,
              end_offset: 3,
              position: 0,
            ),
            Token.new(value: "st", start_offset: 4, end_offset: 6, position: 1),
          ])]
          expected_street_sequences2 = [Token::Sequence.new(tokens: [
            Token.new(
              value: "baz",
              start_offset: 0,
              end_offset: 3,
              position: 0,
            ),
            Token.new(value: "st", start_offset: 4, end_offset: 6, position: 1),
          ])]
          [
            [expected_city_sequences, expected_street_sequences1],
            [expected_city_sequences, expected_street_sequences2],
          ].each_with_index do |expected_sequences, i|
            candidate = candidates[i]

            assert_sequence_array_equality expected_sequences[0], candidate.component(:city).sequences
            assert_sequence_array_equality expected_sequences[1], candidate.component(:street).sequences
          end
        end

        test "#set_candidate_sequences sets sequences for multi value components" do
          candidates = [candidate("1")]
          term_vectors = TermVectors.new(term_vectors_hashes: term_vectors_multi_value, candidates: candidates)
          term_vectors.set_candidate_sequences

          expected_sequences = [
            Token::Sequence.new(tokens: [
              Token.new(value: "new", start_offset: 0, end_offset: 3, position: 0),
              Token.new(value: "york", start_offset: 4, end_offset: 8, position: 1),
            ]),
            Token::Sequence.new(tokens: [
              Token.new(value: "canal", start_offset: 0, end_offset: 5, position: 0),
              Token.new(value: "street", start_offset: 6, end_offset: 12, position: 1),
            ]),
            Token::Sequence.new(tokens: [
              Token.new(value: "chinatown", start_offset: 0, end_offset: 9, position: 0),
            ]),
          ]
          city_sequences = candidates.first.component(:city).sequences
          assert_sequence_array_equality expected_sequences, city_sequences
        end

        test "#set_candidate_sequences assigns tokens from x_decompounded field to candidate's x component" do
          candidate = AddressValidation::Candidate.new(id: "1", source: { street: "Zergstrasse", country_code: "DE" })

          term_vectors_hash = {
            "_id" => "1",
            "term_vectors" => {
              "street_decompounded" => {
                "terms" => {
                  "strasse" => {
                    "term_freq" => 1,
                    "tokens" => [
                      {
                        "position" => 1,
                        "start_offset" => 4,
                        "end_offset" => 11,
                      },
                    ],
                  },
                  "zerg" => {
                    "term_freq" => 1,
                    "tokens" => [
                      {
                        "position" => 0,
                        "start_offset" => 0,
                        "end_offset" => 4,
                      },
                    ],
                  },
                },
              },
            },
          }

          term_vectors = TermVectors.new(term_vectors_hashes: [term_vectors_hash], candidates: [candidate])
          term_vectors.set_candidate_sequences

          expected_sequences = [
            Token::Sequence.new(tokens: [
              Token.new(value: "zerg", start_offset: 0, end_offset: 4, position: 0),
              Token.new(value: "strasse", start_offset: 4, end_offset: 11, position: 1),
            ]),
          ]

          assert_sequence_array_equality expected_sequences, T.must(candidate.component(:street)).sequences
        end

        test "#set_candidate_sequences does nothing when term vector has no associated candidate" do
          candidates = [candidate("1"), candidate("100", { street: "Elm Street" })]
          term_vectors = TermVectors.new(term_vectors_hashes: term_vectors_single_value, candidates: candidates)
          term_vectors.set_candidate_sequences

          expected_city_sequences1 = [
            Token::Sequence.new(
              tokens: [Token.new(
                value: "foo",
                start_offset: 0,
                end_offset: 3,
                position: 0,
              )],
            ),
          ]
          expected_city_sequences2 = [
            Token::Sequence.new(
              tokens: [Token.new(
                value: "ottawa",
                start_offset: 0,
                end_offset: 6,
                position: 0,
              )],
            ),
          ]
          expected_street_sequences1 = [Token::Sequence.new(tokens: [
            Token.new(
              value: "bar",
              start_offset: 0,
              end_offset: 3,
              position: 0,
            ),
            Token.new(value: "st", start_offset: 4, end_offset: 6, position: 1),
          ])]
          expected_street_sequences2 = [Token::Sequence.new(tokens: [
            Token.new(
              value: "elm",
              start_offset: 0,
              end_offset: 3,
              position: 0,
            ),
            Token.new(value: "street", start_offset: 4, end_offset: 10, position: 1),
          ])]
          [
            [expected_city_sequences1, expected_street_sequences1],
            [expected_city_sequences2, expected_street_sequences2],
          ].each_with_index do |expected_sequences, i|
            candidate = candidates[i]

            assert_sequence_array_equality expected_sequences[0], candidate.component(:city).sequences
            assert_sequence_array_equality expected_sequences[1], candidate.component(:street).sequences
          end
        end

        private

        def candidate(id, source = {})
          default_address = {
            street: "Elgin Street",
            city: ["Ottawa"],
            zip: "K2P 1L4",
            province_code: "ON",
            country_code: "CA",
          }
          candidate_hash = default_address.merge(source)
          AddressValidation::Candidate.new(id: id, source: candidate_hash)
        end

        def term_vectors_single_value
          [
            {
              "_id" => "1",
              "term_vectors" => {
                "city_aliases.alias" => {
                  "terms" => {
                    "foo" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 0,
                          "start_offset" => 0,
                          "end_offset" => 3,
                        },
                      ],
                    },
                  },
                },
                "street" => {
                  "terms" => {
                    "bar" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 0,
                          "start_offset" => 0,
                          "end_offset" => 3,
                        },
                      ],
                    },
                    "st" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 1,
                          "start_offset" => 4,
                          "end_offset" => 6,
                        },
                      ],
                    },
                  },
                },
              },
            },
            {
              "_id" => "2",
              "term_vectors" => {
                "city_aliases.alias" => {
                  "terms" => {
                    "francisco" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 1,
                          "start_offset" => 4,
                          "end_offset" => 13,
                        },
                      ],
                    },
                    "foo" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 0,
                          "start_offset" => 0,
                          "end_offset" => 3,
                        },
                      ],
                    },
                  },
                },
                "street" => {
                  "terms" => {
                    "baz" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 0,
                          "start_offset" => 0,
                          "end_offset" => 3,
                        },
                      ],
                    },
                    "st" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 1,
                          "start_offset" => 4,
                          "end_offset" => 6,
                        },
                      ],
                    },
                  },
                },
              },
            },
          ]
        end

        def term_vectors_multi_value
          [
            {
              "_id" => "1",
              "term_vectors" => {
                "city_aliases.alias" => {
                  "terms" => {
                    "canal" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 102,
                          "start_offset" => 9,
                          "end_offset" => 14,
                        },
                      ],
                    },
                    "chinatown" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 204,
                          "start_offset" => 22,
                          "end_offset" => 31,
                        },
                      ],
                    },
                    "new" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 0,
                          "start_offset" => 0,
                          "end_offset" => 3,
                        },
                      ],
                    },
                    "street" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 103,
                          "start_offset" => 15,
                          "end_offset" => 21,
                        },
                      ],
                    },
                    "york" => {
                      "term_freq" => 1,
                      "tokens" => [
                        {
                          "position" => 1,
                          "start_offset" => 4,
                          "end_offset" => 8,
                        },
                      ],
                    },
                  },
                },
              },
            },
          ]
        end
      end
    end
  end
end
