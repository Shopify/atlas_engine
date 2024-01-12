# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    class Token
      class SequenceTest < ActiveSupport::TestCase
        include AddressValidation::TokenHelper

        test "single token sequence" do
          hash = {
            value: "A",
            start_offset: 0,
            end_offset: 10,
            position: 0,
          }
          token = AddressValidation::Token.new(**hash)

          sequence = AddressValidation::Token::Sequence.new(tokens: [token])
          assert_equal token, sequence.tokens.first
        end

        test "two token sequence" do
          tokens =
            [
              {
                value: "A",
                start_offset: 0,
                end_offset: 10,
                position: 0,
              },
              {
                value: "B",
                start_offset: 11,
                end_offset: 13,
                position: 1,
              },
            ].map { |hash| AddressValidation::Token.new(**hash) }

          sequence = AddressValidation::Token::Sequence.new(tokens: tokens)
          assert_equal tokens.first, sequence.tokens.first
          assert_equal tokens.second, sequence.tokens.second
        end

        test "tokens are sorted" do
          tokens =
            [
              {
                value: "A",
                start_offset: 0,
                end_offset: 10,
                position: 1,
              },
              {
                value: "B",
                start_offset: 11,
                end_offset: 13,
                position: 0,
              },
            ].map { |hash| AddressValidation::Token.new(**hash) }

          sequence = AddressValidation::Token::Sequence.new(tokens: tokens)
          assert_equal tokens.second, sequence.tokens.first
          assert_equal tokens.first, sequence.tokens.second
        end

        test "#initialize returns token and synonym sequences" do
          tokens =
            [
              { value: "the", start_offset: 0, end_offset: 3, type: "<ALPHANUM>", position: 0 },
              { value: "2", start_offset: 4, end_offset: 5, type: "<NUM>", position: 1 },
              { value: "quick", start_offset: 6, end_offset: 11, type: "SYNONYM", position: 2 },
              { value: "fast", start_offset: 6, end_offset: 11, type: "SYNONYM", position: 2 },
              { value: "brown", start_offset: 12, end_offset: 17, type: "<ALPHANUM>", position: 3 },
              { value: "foxes", start_offset: 18, end_offset: 23, type: "<ALPHANUM>", position: 4 },
              { value: "jumped", start_offset: 24, end_offset: 30, type: "<ALPHANUM>", position: 5 },
            ].map { |hash| AddressValidation::Token.new(**hash) }

          result = AddressValidation::Token::Sequence.new(tokens: tokens)

          sequence = as_hash_array(result)
          synonym_sequence = sequence.third[:tokens]
          hashed_synonyms = as_hash_array(synonym_sequence)

          assert_equal 6, sequence.count
          assert_equal tokens.first, result.tokens.first
          assert_equal tokens.second, result.tokens.second

          assert_equal 2, synonym_sequence.count
          assert synonym_sequence.is_a?(Array)
          assert hashed_synonyms.all? { |v| v[:type] == "SYNONYM" }
          assert_equal "quick", hashed_synonyms.first[:value]
          assert_equal "fast", hashed_synonyms.second[:value]
        end

        test "#initialize returns token for single-token, multi-token sequence, synonym, and multi-token synonym" do
          tokens = [
            { value: "afb", start_offset: 0, end_offset: 3, type: "SYNONYM", position: 0, position_length: 3 },
            { value: "air", start_offset: 0, end_offset: 3, type: "SYNONYM", position: 0 },
            { value: "force", start_offset: 0, end_offset: 3, type: "SYNONYM", position: 1 },
            { value: "base", start_offset: 0, end_offset: 3, type: "SYNONYM", position: 2 },
          ].map { |hash| AddressValidation::Token.new(**hash) }

          result = AddressValidation::Token::Sequence.new(tokens: tokens)

          sequence = as_hash_array(result)

          synonym_sequence = sequence.first[:tokens]
          hashed_synonyms = as_hash_array(synonym_sequence)
          air_force_base = hashed_synonyms.second

          assert_equal 2, hashed_synonyms.count

          assert_token(data: hashed_synonyms.first, value: "afb", s_offset: 0, e_offset: 3, pos: 0, pos_len: 3)

          assert_equal 3, air_force_base.count
          assert_token(data: air_force_base.first, value: "air", s_offset: 0, e_offset: 3, pos: 0)
          assert_token(data: air_force_base.second, value: "force", s_offset: 0, e_offset: 3, pos: 1)
          assert_token(data: air_force_base.third, value: "base", s_offset: 0, e_offset: 3, pos: 2)
        end

        test "#initialize groups multi-token synonym tokens according to their natural ordering, position and \
            position length" do
          # e.g. analyzing "northwest 48th avenue" with the street_synonyms analyzer
          tokens = [
            { value: "north", start_offset: 0, end_offset: 9, type: "SYNONYM", position: 0 },
            { value: "nw", start_offset: 0, end_offset: 9, type: "SYNONYM", position: 0, position_length: 2 },
            { value: "northwest", start_offset: 0, end_offset: 9, type: "SYNONYM", position: 0, position_length: 2 },
            { value: "west", start_offset: 0, end_offset: 9, type: "SYNONYM", position: 1 },
            { value: "48th", start_offset: 10, end_offset: 14, type: "SYNONYM", position: 2 },
            { value: "avenu", start_offset: 15, end_offset: 21, type: "SYNONYM", position: 3 },
            { value: "aven", start_offset: 15, end_offset: 21, type: "SYNONYM", position: 3 },
            { value: "av", start_offset: 15, end_offset: 21, type: "SYNONYM", position: 3 },
            { value: "ave", start_offset: 15, end_offset: 21, type: "SYNONYM", position: 3 },
            { value: "avenue", start_offset: 15, end_offset: 21, type: "SYNONYM", position: 3 },
          ].map { |hash| AddressValidation::Token.new(**hash) }

          result = AddressValidation::Token::Sequence.new(tokens: tokens)

          sequence = as_hash_array(result)

          nw_synonym_sequence = sequence.first[:tokens]
          nw_hashed_synonyms = as_hash_array(nw_synonym_sequence)

          assert_equal 3, nw_hashed_synonyms.count

          north_west = nw_hashed_synonyms[0]

          assert_instance_of Array, north_west
          assert_equal 2, north_west.count
          assert_token(data: north_west.first, value: "north", s_offset: 0, e_offset: 9, pos: 0)
          assert_token(data: north_west.second, value: "west", s_offset: 0, e_offset: 9, pos: 1)

          assert_token(data: nw_hashed_synonyms[1], value: "nw", s_offset: 0, e_offset: 9, pos: 0, pos_len: 2)
          assert_token(data: nw_hashed_synonyms[2], value: "northwest", s_offset: 0, e_offset: 9, pos: 0, pos_len: 2)
          assert_token(data: sequence.second, value: "48th", s_offset: 10, e_offset: 14, pos: 2)

          ave_synonym_sequence = sequence[2][:tokens]
          ave_hashed_synonyms = as_hash_array(ave_synonym_sequence)

          assert_equal 5, ave_hashed_synonyms.count
          assert_token(data: ave_hashed_synonyms[0], value: "avenu", s_offset: 15, e_offset: 21, pos: 3)
          assert_token(data: ave_hashed_synonyms[1], value: "aven", s_offset: 15, e_offset: 21, pos: 3)
          assert_token(data: ave_hashed_synonyms[2], value: "av", s_offset: 15, e_offset: 21, pos: 3)
          assert_token(data: ave_hashed_synonyms[3], value: "ave", s_offset: 15, e_offset: 21, pos: 3)
          assert_token(data: ave_hashed_synonyms[4], value: "avenue", s_offset: 15, e_offset: 21, pos: 3)
        end

        test "#initialize groups synonym tokens having overlapping offsets" do
          # e.g. analyzing "farm to market rd 1138" with the street_synonyms analyzer.
          # assume that the relevant synonyms are:
          # - - farm to market
          #   - hwy fm
          #   - fm
          # ...
          # - - road
          #   - rd
          tokens = [
            { value: "hwy", start_offset: 0, end_offset: 14, type: "SYNONYM", position: 0 },
            { value: "fm", start_offset: 0, end_offset: 14, type: "SYNONYM", position: 0, position_length: 4 },
            { value: "farm", start_offset: 0, end_offset: 4, type: "<ALPHANUM>", position: 0, position_length: 2 },
            { value: "fm", start_offset: 0, end_offset: 14, type: "SYNONYM", position: 1, position_length: 3 },
            { value: "to", start_offset: 5, end_offset: 7, type: "<ALPHANUM>", position: 2 },
            { value: "market", start_offset: 8, end_offset: 14, type: "<ALPHANUM>", position: 3 },
            { value: "road", start_offset: 15, end_offset: 17, type: "SYNONYM", position: 4 },
            { value: "rd", start_offset: 15, end_offset: 17, type: "<ALPHANUM>", position: 4 },
            { value: "1138", start_offset: 18, end_offset: 22, type: "NUM>", position: 5 },
          ].map { |hash| AddressValidation::Token.new(**hash) }

          result = AddressValidation::Token::Sequence.new(tokens: tokens)

          sequence = as_hash_array(result)
          assert_equal 3, sequence.count

          # farm-to-market synonyms
          fm_synonym_sequence = sequence[0][:tokens]
          fm_hashed_synonyms = as_hash_array(fm_synonym_sequence)

          assert_equal 3, fm_hashed_synonyms.count

          hwy_fm = fm_hashed_synonyms[0]

          assert_instance_of Array, hwy_fm
          assert_equal 2, hwy_fm.count
          assert_token(data: hwy_fm.first, value: "hwy", s_offset: 0, e_offset: 14, pos: 0)
          assert_token(data: hwy_fm.second, value: "fm", s_offset: 0, e_offset: 14, pos: 1, pos_len: 3)

          assert_token(data: fm_hashed_synonyms[1], value: "fm", s_offset: 0, e_offset: 14, pos: 0, pos_len: 4)

          farm_to_market = fm_hashed_synonyms[2]

          assert_instance_of Array, farm_to_market
          assert_equal 3, farm_to_market.count
          assert_token(data: farm_to_market[0], value: "farm", s_offset: 0, e_offset: 4, pos: 0, pos_len: 2)
          assert_token(data: farm_to_market[1], value: "to", s_offset: 5, e_offset: 7, pos: 2)
          assert_token(data: farm_to_market[2], value: "market", s_offset: 8, e_offset: 14, pos: 3)

          # road synonyms
          rd_synonym_sequence = sequence[1][:tokens]
          rd_hashed_synonyms = as_hash_array(rd_synonym_sequence)

          assert_equal 2, rd_hashed_synonyms.count

          assert_token(data: rd_hashed_synonyms[0], value: "road", s_offset: 15, e_offset: 17, pos: 4)
          assert_token(data: rd_hashed_synonyms[1], value: "rd", s_offset: 15, e_offset: 17, pos: 4)

          # route number 1138
          assert_token(data: sequence[2], value: "1138", s_offset: 18, e_offset: 22, pos: 5)
        end

        test "from_string returns an empty sequence for nil" do
          assert_predicate AddressValidation::Token::Sequence.from_string(nil).tokens, :empty?
        end

        test "from_string segments tokens according to the Annex-29 Unicode text segmentation rules" do
          # https://www.elastic.co/guide/en/elasticsearch/reference/7.17/analysis-standard-tokenizer.html

          expected_token_values = [
            { value: "the", start_offset: 0, end_offset: 3, type: "<ALPHANUM>", position: 0, position_length: 1 },
            { value: "2", start_offset: 4, end_offset: 5, type: "<NUM>", position: 1, position_length: 1 },
            { value: "quick", start_offset: 6, end_offset: 11, type: "<ALPHANUM>", position: 2, position_length: 1 },
            { value: "brown", start_offset: 12, end_offset: 17, type: "<ALPHANUM>", position: 3, position_length: 1 },
            { value: "foxes", start_offset: 18, end_offset: 23, type: "<ALPHANUM>", position: 4, position_length: 1 },
            { value: "jum", start_offset: 24, end_offset: 27, type: "<ALPHANUM>", position: 5, position_length: 1 },
            { value: "ped", start_offset: 40, end_offset: 43, type: "<ALPHANUM>", position: 6, position_length: 1 },
            { value: "over", start_offset: 44, end_offset: 48, type: "<ALPHANUM>", position: 7, position_length: 1 },
            { value: "the", start_offset: 49, end_offset: 52, type: "<ALPHANUM>", position: 8, position_length: 1 },
            { value: "lazy", start_offset: 53, end_offset: 57, type: "<ALPHANUM>", position: 9, position_length: 1 },
            { value: "dogs", start_offset: 58, end_offset: 63, type: "<ALPHANUM>", position: 10, position_length: 1 },
            { value: "bone", start_offset: 64, end_offset: 68, type: "<ALPHANUM>", position: 11, position_length: 1 },
          ]

          string = "The 2 QUICK Brown-Foxes jum!@%&\"'*,.();:ped over the lazy dog's bone."
          sequence = AddressValidation::Token::Sequence.from_string(string)

          assert_equal expected_token_values, as_hash_array(sequence)
        end

        test "from_string supports input written in non-Latin scripts" do
          expected_hangul_token_values = [
            { value: "고양시", start_offset: 0, end_offset: 3, type: "<ALPHANUM>", position: 0, position_length: 1 },
            { value: "일산동구", start_offset: 4, end_offset: 8, type: "<ALPHANUM>", position: 1, position_length: 1 },
          ]
          expected_arabic_token_values = [
            { value: "الطايف", start_offset: 0, end_offset: 6, type: "<ALPHANUM>", position: 0, position_length: 1 },
          ]

          hangul_string = "고양시 일산동구"
          arabic_string = "الطايف"

          hangul_sequence = AddressValidation::Token::Sequence.from_string(hangul_string)
          arabic_sequence = AddressValidation::Token::Sequence.from_string(arabic_string)

          assert_equal expected_hangul_token_values, as_hash_array(hangul_sequence)
          assert_equal expected_arabic_token_values, as_hash_array(arabic_sequence)
        end

        test "from_string strips diacritics and ligatures" do
          expected_token_values = [
            { value: "beloeil", start_offset: 0, end_offset: 6, type: "<ALPHANUM>", position: 0, position_length: 1 },
            { value: "les", start_offset: 7, end_offset: 10, type: "<ALPHANUM>", position: 1, position_length: 1 },
            { value: "pont", start_offset: 11, end_offset: 15, type: "<ALPHANUM>", position: 2, position_length: 1 },
            { value: "a", start_offset: 16, end_offset: 17, type: "<ALPHANUM>", position: 3, position_length: 1 },
            { value: "mousson", start_offset: 18, end_offset: 25, type: "<ALPHANUM>", position: 4, position_length: 1 },
          ]

          string = "Belœil-lès-Pont-à-Mousson"
          sequence = AddressValidation::Token::Sequence.from_string(string)

          assert_equal expected_token_values, as_hash_array(sequence)
        end

        test "#inspect returns tokens" do
          t1 = token(value: "A", start_offset: 0, end_offset: 5)
          t2 = token(value: "Eh!", start_offset: 3, end_offset: 6, position: 1)
          sequence = AddressValidation::Token::Sequence.new(tokens: [t1, t2])
          assert_match(
            %r{<seq \[<tok id:\d{4} val:"A" strt:0 end:5 pos:0/>, <tok id:\d{4} val:"Eh!" strt:3 end:6 pos:1/>\]/>},
            sequence.inspect,
          )
        end

        test "#inspect returns synonyms if offsets of tokens are the same value" do
          t1 = token(value: "A", start_offset: 3, end_offset: 6)
          t2 = token(value: "Eh!", start_offset: 3, end_offset: 6)
          synonyms = AddressValidation::Token::Sequence.new(tokens: [t1, t2])

          synonym1 = '<tok id:\d{4} val:"A" strt:3 end:6 pos:0/>'
          synonym2 = '<tok id:\d{4} val:"Eh!" strt:3 end:6 pos:0/>'
          assert_match(
            %r{<seq \[<syn \[#{synonym1}, #{synonym2}\]/>\]/>},
            synonyms.inspect,
          )
        end

        test "#inspect returns synonyms if offsets of tokens are the same value and we have multi-tokens" do
          t1 = token(value: "A", start_offset: 3, end_offset: 6)
          t2 = token(value: "Eh!", start_offset: 3, end_offset: 6, position_length: 2)
          t3 = token(value: "Quest", start_offset: 3, end_offset: 6, position: 1)
          synonyms = AddressValidation::Token::Sequence.new(tokens: [t1, t2, t3])

          synonym1 = '<tok id:\d{4} val:"A" strt:3 end:6 pos:0/>'
          synonym2 = '<tok id:\d{4} val:"Eh!" strt:3 end:6 pos:0 pos_length:2/>'
          synonym3 = '<tok id:\d{4} val:"Quest" strt:3 end:6 pos:1/>'

          assert_match(
            %r{<seq \[<syn \[\[#{synonym1}, #{synonym3}\], #{synonym2}\]/>\]/>},
            synonyms.inspect,
          )
        end

        test "#permutations returns one permutation for a sequence without synonyms" do
          t1 = token(value: "123", position: 0, end_offset: 3)
          t2 = token(value: "elgin", position: 1, start_offset: 4, end_offset: 9)
          t3 = token(value: "street", position: 2, start_offset: 10, end_offset: 16)
          synonyms = AddressValidation::Token::Sequence.new(tokens: [t1, t2, t3])

          result = synonyms.permutations

          match1 = [t1, t2, t3]

          assert_equal 1, result.count
          assert_same_elements [match1], result
        end

        test "#permutations returns one permutation for a sequence with single-token synonyms" do
          t1 = token(value: "123", position: 0, end_offset: 3)
          t2 = token(value: "elgin", position: 1, start_offset: 4, end_offset: 9)
          t3 = token(value: "st", position: 2, start_offset: 10, end_offset: 12)
          t4 = token(value: "street", position: 2, start_offset: 10, end_offset: 12)
          synonyms = AddressValidation::Token::Sequence.new(tokens: [t1, t2, t3, t4])

          result = synonyms.permutations

          match1 = [t1, t2, t3, t4]

          assert_equal 1, result.count
          assert_same_elements [match1], result
        end

        test "#permutations returns one permutation per entry in a with multi-token synonyms group" do
          t1 = token(value: "123", position: 0, end_offset: 3)
          t2 = token(value: "elgin", position: 1, start_offset: 4, end_offset: 9)
          t3 = token(value: "afb", position: 2, position_length: 3, start_offset: 10, end_offset: 13)
          t4 = token(value: "air", position: 2, start_offset: 10, end_offset: 13)
          t5 = token(value: "force", position: 3, start_offset: 10, end_offset: 13)
          t6 = token(value: "base", position: 4, start_offset: 10, end_offset: 13)
          synonyms = AddressValidation::Token::Sequence.new(tokens: [t1, t2, t3, t4, t5, t6])

          result = synonyms.permutations

          match1 = [t1, t2, t3]
          match2 = [t1, t2, t4, t5, t6]

          assert_equal 2, result.count
          assert_same_elements [match1, match2], result
        end

        test "#permutations returns 4 permutations for two multi-token synonym groups, each of size 2" do
          t1 = token(value: "123", position: 0, end_offset: 3)
          t2 = token(value: "elgin", position: 1, start_offset: 4, end_offset: 9)
          t3 = token(value: "afb", position: 2, position_length: 3, start_offset: 10, end_offset: 13)
          t4 = token(value: "air", position: 2, start_offset: 10, end_offset: 13)
          t5 = token(value: "force", position: 3, start_offset: 10, end_offset: 13)
          t6 = token(value: "base", position: 4, start_offset: 10, end_offset: 13)
          t7 = token(value: "ny", position: 5, position_length: 2, start_offset: 14, end_offset: 16)
          t8 = token(value: "new", position: 5, start_offset: 14, end_offset: 16)
          t9 = token(value: "york", position: 6, start_offset: 14, end_offset: 16)
          synonyms = AddressValidation::Token::Sequence.new(tokens: [t1, t2, t3, t4, t5, t6, t7, t8, t9])

          result = synonyms.permutations

          match1 = [t1, t2, t3, t7]
          match2 = [t1, t2, t3, t8, t9]
          match3 = [t1, t2, t4, t5, t6, t7]
          match4 = [t1, t2, t4, t5, t6, t8, t9]

          assert_equal 4, result.count
          assert_same_elements [match1, match2, match3, match4], result
        end

        test "#permutations returns flattened sequence permutations for multi-token an single token synonyms" do
          t1 = token(value: "123", position: 0, end_offset: 3)
          t2 = token(value: "elgin", position: 1, start_offset: 4, end_offset: 9)
          t3 = token(value: "afb", position: 2, position_length: 3, start_offset: 10, end_offset: 13)
          t4 = token(value: "air", position: 2, start_offset: 10, end_offset: 13)
          t5 = token(value: "force", position: 3, start_offset: 10, end_offset: 13)
          t6 = token(value: "base", position: 4, start_offset: 10, end_offset: 13)
          t7 = token(value: "ny", position: 5, position_length: 2, start_offset: 14, end_offset: 16)
          t8 = token(value: "new", position: 5, start_offset: 14, end_offset: 16)
          t9 = token(value: "york", position: 6, start_offset: 14, end_offset: 16)
          t10 = token(value: "div", position: 7, start_offset: 17, end_offset: 20)
          t11 = token(value: "division", position: 7, start_offset: 17, end_offset: 20)
          synonyms = AddressValidation::Token::Sequence.new(tokens: [t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11])

          result = synonyms.permutations

          match1 = [t1, t2, t3, t7, t10, t11]
          match2 = [t1, t2, t3, t8, t9, t10, t11]
          match3 = [t1, t2, t4, t5, t6, t7, t10, t11]
          match4 = [t1, t2, t4, t5, t6, t8, t9, t10, t11]

          assert_equal 4, result.count
          assert_same_elements [match1, match2, match3, match4], result
        end
      end
    end
  end
end
