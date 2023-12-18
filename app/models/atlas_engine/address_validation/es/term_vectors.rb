# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      class TermVectors
        extend T::Sig

        sig do
          params(
            term_vectors_hashes: T::Array[T::Hash[String, T::Hash[String, T.untyped]]],
            candidates: T::Array[Candidate],
          ).void
        end
        def initialize(term_vectors_hashes:, candidates:)
          @term_vectors_hashes = term_vectors_hashes
          @candidates = candidates
        end

        sig { void }
        def set_candidate_sequences
          candidates_by_id = candidates.index_by(&:id)

          term_vectors_hashes.map do |candidate_result|
            candidate = candidates_by_id[candidate_result["_id"]]

            next if candidate.nil?

            candidate_result["term_vectors"].map do |component_name, terms_hash|
              component_name = component_name.delete_suffix("_decompounded")
              # city values are indexed as city_aliases.alias, but Atlas still uses :city as the component name
              component_name = "city" if component_name == "city_aliases.alias"
              component = candidate.component(component_name.to_sym)
              sorted_tokens = Token.from_field_term_vector(terms_hash)
              set_sequences(component, sorted_tokens)
            end
          end
        end

        private

        attr_reader :term_vectors_hashes, :candidates

        sig do
          params(component: Candidate::Component, sorted_tokens: T::Array[Token]).void
        end
        def set_sequences(component, sorted_tokens)
          grouped_tokens = split_tokens_by_position(sorted_tokens)
          component.sequences = grouped_tokens.map.with_index do |sequence_tokens, value_index|
            # ES' offsets are set as if all tokens are part of one long sequence
            # we adjust the offsets to be relative to the start of each sequence
            offset = T.must(sequence_tokens.first).start_offset
            sequence_tokens.each_with_index do |token, i|
              token.start_offset = token.start_offset - offset
              token.end_offset = token.end_offset - offset
              token.position = i
            end
            Token::Sequence.new(
              tokens: sequence_tokens,
              raw_value: component.values[value_index],
            )
          end
        end

        sig do
          params(tokens: T::Array[Token])
            .returns(T::Enumerable[T::Array[Token]])
        end
        def split_tokens_by_position(tokens)
          tokens.chunk_while do |token, next_token|
            token.preceeds?(next_token)
          end
        end
      end
    end
  end
end
