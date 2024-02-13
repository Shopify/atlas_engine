# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      class Datastore
        include MetricsHelper
        include LogHelper
        include DatastoreBase
        extend T::Sig

        sig { override.returns(CountryProfile) }
        attr_reader :country_profile

        sig { override.returns(ValidationTranscriber::AddressParsings) }
        attr_reader :parsings

        attr_writer :candidates # meant for test setup only

        sig { params(address: AbstractAddress, locale: T.nilable(String)).void }
        def initialize(address:, locale: nil)
          @address = address
          @locale = locale

          raise ArgumentError, "address has no country_code" if address.country_code.blank?

          @country_code = T.must(address.country_code.to_s)
          @country_profile = CountryProfile.for(country_code.to_s.upcase, @locale)

          if locale.nil? && @country_profile.validation.multi_locale?
            raise ArgumentError, "#{country_code} is a multi-locale country and requires a locale"
          end

          @parsings = ValidationTranscriber::AddressParsings.new(address_input: address, locale: locale)
          @query_builder = QueryBuilder.for(address, parsings, locale)
        end

        sig do
          returns(CountryRepository)
        end
        def repository
          @repository ||= CountryRepository.new(
            country_code: country_code.downcase,
            repository_class: AtlasEngine.elasticsearch_repository.constantize,
            locale: locale&.downcase,
            index_configuration: nil,
          )
        end

        sig { params(sequence: Token::Sequence).void }
        def city_sequence=(sequence)
          @city_sequence_future = Concurrent::Promises.fulfilled_future(sequence)
        end

        sig { override.returns(Token::Sequence) }
        def fetch_city_sequence
          log_future_state_on_join(future: @city_sequence_future, method: "city_sequence")

          @city_sequence_future ||= Concurrent::Promises.fulfilled_future(fetch_city_sequence_internal)

          @city_sequence_future.value!
        end

        sig { returns(Concurrent::Promises::Future) }
        def fetch_city_sequence_async
          submit_time = Time.current

          @city_sequence_future ||= Concurrent::Promises.future do
            measure_future_queue_time(enqueue_time: submit_time, method: "city_sequence")
            fetch_city_sequence_internal
          end
        end

        sig { params(sequences: T::Array[Token::Sequence]).void }
        def street_sequences=(sequences)
          @street_sequences_future = Concurrent::Promises.fulfilled_future(sequences)
        end

        sig { override.returns(T::Array[Token::Sequence]) }
        def fetch_street_sequences
          log_future_state_on_join(future: @street_sequences_future, method: "all_street_sequences")

          @street_sequences_future ||= Concurrent::Promises.fulfilled_future(fetch_street_sequences_internal)

          @street_sequences_future.value!
        end

        sig { returns(Concurrent::Promises::Future) }
        def fetch_street_sequences_async
          submit_time = Time.current

          @street_sequences_future ||= Concurrent::Promises.future do
            measure_future_queue_time(enqueue_time: submit_time, method: "all_street_sequences")
            fetch_street_sequences_internal
          end
        end

        sig { override.returns(T::Array[Candidate]) }
        def fetch_full_address_candidates
          @candidates ||= fetch_addresses_internal.map { |address| Candidate.from(address) }.tap do |candidates|
            assign_term_vectors_to_candidates(candidates) if candidates.present?
          end
        end

        sig { override.returns(Hash) }
        def validation_response
          {
            body: fetch_addresses_internal,
          }
        end

        private

        attr_reader :address, :country_code, :locale, :query_builder

        sig { returns(Token::Sequence) }
        def fetch_city_sequence_internal
          city_value = address.city
          request = {
            analyzer: :city_analyzer,
            text: city_value,
          }

          measure_es_validation_request_time(method: "city_sequence") do
            tokens = repository.analyze(request).map do |token|
              Token.from_analyze(token)
            end
            Token::Sequence.new(tokens: tokens, raw_value: city_value)
          end
        end

        sig { returns(T::Array[T::Hash[String, T.untyped]]) }
        def fetch_addresses_internal
          measure_es_validation_request_time(method: "full_address_candidates") do
            repository.search(query_builder.full_address_query)
          end
        end

        sig { returns(T::Array[Token::Sequence]) }
        def fetch_street_sequences_internal
          measure_es_validation_request_time(method: "all_street_sequences") do
            @parsings.potential_streets.map do |street_address_value|
              request = {
                analyzer: :street_analyzer,
                text: prepare_street_for_analysis(street_address_value),
              }

              measure_es_validation_request_time(method: "street_sequence") do
                tokens = repository.analyze(request).map do |token|
                  Token.from_analyze(token)
                end
                Token::Sequence.new(tokens: tokens, raw_value: street_address_value)
              end
            end
          end
        end

        sig { params(candidates: T::Array[Candidate]).void }
        def assign_term_vectors_to_candidates(candidates)
          return if country_profile.validation.normalized_components.blank?

          candidate_term_vectors = measure_es_validation_request_time(method: "term_vectors") do
            repository.term_vectors(term_vectors_query(candidates))
          end

          TermVectors.new(term_vectors_hashes: candidate_term_vectors, candidates: candidates).set_candidate_sequences
        end

        sig { params(candidates: T::Array[Candidate]).returns(T::Hash[String, T.untyped]) }
        def term_vectors_query(candidates)
          {
            ids: candidates.map(&:id),
            parameters: {
              fields: country_profile.validation.normalized_components,
              field_statistics: false,
            },
          }
        end

        sig { params(method: String, block: T.proc.returns(T.untyped)).returns(T.untyped) }
        def measure_es_validation_request_time(method:, &block)
          measure_distribution(
            name: "AddressValidation.elasticsearch_request_time_dist",
            tags: [
              "country:#{country_code}",
              "method:#{method}",
            ],
            &block
          )
        end

        sig { params(future: T.nilable(Concurrent::Promises::Future), method: String).void }
        def log_future_state_on_join(future:, method:)
          state = future&.state || :unsubmitted
          log_warn("Joining with #{state} future, method: #{method}") unless state == :fulfilled

          StatsD.increment(
            "AddressValidation.elasticsearch_future_state",
            sample_rate: 1.0,
            tags: {
              country: country_code,
              method:,
              state:,
            },
          )
        end

        sig { params(enqueue_time: ActiveSupport::TimeWithZone, method: String).void }
        def measure_future_queue_time(enqueue_time:, method:)
          StatsD.distribution(
            "AddressValidation.elasticsearch_future_queue_time",
            Time.current - enqueue_time,
            tags: [
              "country:#{country_code}",
              "method:#{method}",
            ],
          )
        end

        sig { params(street_value: String).returns(String) }
        def prepare_street_for_analysis(street_value)
          T.must(
            FieldDecompounder.new(
              field: :street,
              value: street_value,
              country_profile:,
            ).call,
          )
        end
      end
    end
  end
end
