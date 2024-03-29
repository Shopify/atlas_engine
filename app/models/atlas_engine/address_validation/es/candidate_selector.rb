# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      class CandidateSelector
        include LogHelper
        extend T::Sig

        sig { params(datastore: DatastoreBase, address: AbstractAddress).void }
        def initialize(datastore:, address:)
          @datastore = T.let(datastore, DatastoreBase)
          @address = T.let(address, AbstractAddress)
        end

        sig { returns(Concurrent::Promises::Future) }
        def best_candidate_async
          Concurrent::Promises.future do
            best_candidate
          end
        end

        sig { returns(T.nilable(AddressValidation::Validators::FullAddress::AddressComparison)) }
        def best_candidate
          street_sequences_future = datastore.fetch_street_sequences_async
          city_sequences_future = datastore.fetch_city_sequence_async
          sorted_candidates.first
        ensure
          # We want our futures to complete even when we do not consume their value.
          street_sequences_future&.wait!
          city_sequences_future&.wait!
        end

        private

        attr_reader :datastore, :address

        sig { returns(T::Array[AddressValidation::Validators::FullAddress::AddressComparison]) }
        def sorted_candidates
          sorted_address_comparisons = datastore.fetch_full_address_candidates
            .filter_map.with_index(1) do |candidate, position|
              candidate.position = position
              address_comparison = AddressValidation::Validators::FullAddress::AddressComparison.new(
                address: address,
                candidate: candidate,
                datastore: datastore,
              )
              address_comparison if address_comparison.potential_match?
            end.sort

          emit_sorted_candidates(sorted_address_comparisons.map(&:candidate))
          sorted_address_comparisons
        end

        sig { params(sorted_candidates: T::Array[Candidate]).void }
        def emit_sorted_candidates(sorted_candidates)
          log_info("Sorted candidates:\n #{sorted_candidates.map(&:serialize)}")

          initial_position_top_candidate = sorted_candidates.first&.position || 0
          StatsD.distribution(
            "AddressValidation.query.initial_position_top_candidate",
            initial_position_top_candidate,
            tags: { position: initial_position_top_candidate },
          )
        end
      end
    end
  end
end
