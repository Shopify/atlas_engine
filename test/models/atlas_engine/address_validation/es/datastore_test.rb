# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Es
      class DatastoreTest < ActiveSupport::TestCase
        include StatsD::Instrument::Assertions
        include AddressValidation::AddressValidationTestHelper
        include AddressValidation::TokenHelper

        setup do
          @datastore = AddressValidation::Es::Datastore.new(address: address)
          @headers = { "Content-Type" => "application/json" }
        end

        test "#initialize raises an argument error if the address has no country code" do
          assert_raises(ArgumentError) do
            AddressValidation::Es::Datastore.new(address: build_address)
          end
        end

        test "#initialize raises an argument error if the address is in a multi-locale country with no locale" do
          assert_raises(ArgumentError) do
            AddressValidation::Es::Datastore.new(address: build_address(country_code: "CH"))
          end
        end

        test "datastore can be initialized with a locale in a multi-locale country" do
          datastore = AddressValidation::Es::Datastore.new(address: build_address(country_code: "CH"), locale: "de")
          assert_equal "test_ch_de", datastore.repository.active_alias
        end

        test "#fetch_city_sequence returns a sequence of tokens for the address' city" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .with(body: { analyzer: "city_analyzer", text: "San Francisco" })
            .to_return(status: 200, body: analyze_query_results.to_json, headers: @headers)

          sequence = @datastore.fetch_city_sequence
          assert_equal sequence.size, 2
          assert_equal "San Francisco", sequence.raw_value
        end

        test "#fetch_city_sequence does not call ES for the same query" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .to_return(status: 200, body: analyze_query_results.to_json, headers: @headers)

          @datastore.fetch_city_sequence
          @datastore.fetch_city_sequence

          assert_requested(:post, %r{http\://.*/test_us/_analyze}, times: 1)
        end

        test "#fetch_city_sequence returns empty sequence on bad ES response" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .with(body: { analyzer: "city_analyzer", text: "San Francisco" })
            .to_return(status: 400, body: "", headers: @headers)

          sequence = @datastore.fetch_city_sequence
          assert_empty sequence
        end

        test "#fetch_city_sequence does not call ES for the same query even when there is no response" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .to_return(status: 200, body: { "tokens": [] }.to_json, headers: @headers)

          @datastore.fetch_city_sequence
          @datastore.fetch_city_sequence

          assert_requested(:post, %r{http\://.*/test_us/_analyze}, times: 1)
        end

        test "#fetch_city_sequence measures the time to retrieve tokens" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .to_return(status: 200, body: analyze_query_results.to_json, headers: @headers)

          assert_statsd_distribution(
            "AddressValidation.elasticsearch_request_time_dist",
            tags: ["country:US", "method:city_sequence"],
          ) do
            @datastore.fetch_city_sequence
          end
        end

        test "#fetch_city_sequence records an unsubmitted future state if no future was previously started" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .to_return(status: 200, body: analyze_query_results.to_json, headers: @headers)

          assert_statsd_increment(
            "AddressValidation.elasticsearch_future_state",
            tags: ["country:US", "method:city_sequence", "state:unsubmitted"],
          ) do
            @datastore.fetch_city_sequence
          end
        end

        test "#fetch_city_sequence records the state of an unresolved async future at the time of the call" do
          delayed_future = Concurrent::Promises.delay do
            AtlasEngine::AddressValidation::Token::Sequence.from_string("")
          end
          @datastore.instance_variable_set(:@city_sequence_future, delayed_future)

          assert_statsd_increment(
            "AddressValidation.elasticsearch_future_state",
            tags: ["country:US", "method:city_sequence", "state:pending"],
          ) do
            @datastore.fetch_city_sequence
          end

          assert_predicate delayed_future, :fulfilled?
        end

        test "#fetch_city_sequence records the state of a resolved async future at the time of the call" do
          @datastore.city_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string("")

          assert_statsd_increment(
            "AddressValidation.elasticsearch_future_state",
            tags: ["country:US", "method:city_sequence", "state:fulfilled"],
          ) do
            @datastore.fetch_city_sequence
          end
        end

        test "#fetch_city_sequence_async returns a pending future that resolves as a sequence" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .with(body: { analyzer: "city_analyzer", text: "San Francisco" })
            .to_return(status: 200, body: analyze_query_results.to_json, headers: @headers)

          future = @datastore.fetch_city_sequence_async
          assert_predicate future, :pending?

          sequence = future.value
          assert_predicate future, :fulfilled?
          assert sequence.is_a?(Token::Sequence)
          assert_equal sequence.size, 2
          assert_equal "San Francisco", sequence.raw_value
        end

        test "#fetch_city_sequence_async returns the same future on subsequent calls" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .with(body: { analyzer: "city_analyzer", text: "San Francisco" })
            .to_return(status: 200, body: analyze_query_results.to_json, headers: @headers)

          future = @datastore.fetch_city_sequence_async

          assert_same future, @datastore.fetch_city_sequence_async
          future.wait # need to wait for the http request to be made before exiting the test
        end

        test "#fetch_city_sequence_async returns a fulfilled future if called after #city_sequence=" do
          sequence = Token::Sequence.from_string("San Francisco")
          @datastore.city_sequence = sequence
          future = @datastore.fetch_city_sequence_async
          assert_predicate future, :fulfilled?

          assert_same sequence, future.value
        end

        test "#fetch_city_sequence_async measures the future's queuing time" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .with(body: { analyzer: "city_analyzer", text: "San Francisco" })
            .to_return(status: 200, body: analyze_query_results.to_json, headers: @headers)

          assert_statsd_distribution(
            "AddressValidation.elasticsearch_future_queue_time",
            tags: ["country:US", "method:city_sequence"],
          ) do
            @datastore.fetch_city_sequence_async.wait
          end
        end

        test "#fetch_city_sequence returns result of async future if called after #fetch_city_sequence_async" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .with(body: { analyzer: "city_analyzer", text: "San Francisco" })
            .to_return(status: 200, body: analyze_query_results.to_json, headers: @headers)

          future = @datastore.fetch_city_sequence_async
          assert_predicate future, :pending?

          sequence = @datastore.fetch_city_sequence

          assert_predicate future, :fulfilled?
          assert_same sequence, future.value
          assert_requested(:post, %r{http\://.*/test_us/_analyze})
        end

        test "#fetch_street_sequences returns an array of sequences of tokens for plausible street names" do
          ["Main Street"].each do |text|
            stub_request(:post, %r{http\://.*/test_us/_analyze})
              .with(body: { analyzer: "street_analyzer", text: })
              .to_return(status: 200, body: analyze_result_for(text).to_json, headers: @headers)
          end

          sequences = @datastore.fetch_street_sequences
          assert sequences.is_a?(Array)
          assert_equal 1, sequences.count
          assert_equal ["main", "street"], sequences[0].tokens.map(&:value)
        end

        test "#fetch_street_sequences decompounds potential street names when decompounding is enabled for :street" do
          ["Haupt strasse"].each do |text|
            stub_request(:post, %r{http\://.*/test_de/_analyze})
              .with(body: { analyzer: "street_analyzer", text: })
              .to_return(status: 200, body: analyze_result_for(text).to_json, headers: @headers)
          end

          german_address = build_address(country_code: "DE", address1: "Hauptstraße 42")

          datastore = AddressValidation::Es::Datastore.new(address: german_address)
          sequences = datastore.fetch_street_sequences
          assert sequences.is_a?(Array)
          assert_equal 1, sequences.count
          assert_equal ["haupt", "strasse"], sequences[0].tokens.map(&:value)
        end

        test "#fetch_street_sequences returns an array of sequences of tokens for po boxes" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .with(body: { analyzer: "street_analyzer", text: "po box" })
            .to_return(status: 200, body: analyze_result_for("po box").to_json, headers: @headers)

          datastore = AddressValidation::Es::Datastore.new(address: address_po_box)
          sequences = datastore.fetch_street_sequences
          assert sequences.is_a?(Array)
          assert_equal 1, sequences.count
          assert_equal ["po", "box"], sequences[0].tokens.map(&:value)
        end

        test "#fetch_street_sequences measures the time to retrieve tokens" do
          ["Main Street"].each do |text|
            stub_request(:post, %r{http\://.*/test_us/_analyze})
              .with(body: { analyzer: "street_analyzer", text: })
              .to_return(status: 200, body: analyze_result_for(text).to_json, headers: @headers)
          end

          assert_statsd_distribution(
            "AddressValidation.elasticsearch_request_time_dist",
            tags: ["country:US", "method:all_street_sequences"],
          ) do
            assert_statsd_distribution(
              "AddressValidation.elasticsearch_request_time_dist",
              tags: ["country:US", "method:street_sequence"],
              times: 1,
            ) do
              @datastore.fetch_street_sequences
            end
          end
        end

        test "#fetch_street_sequences records an unsubmitted future state if no future was previously started" do
          ["Main Street"].each do |text|
            stub_request(:post, %r{http\://.*/test_us/_analyze})
              .with(body: { analyzer: "street_analyzer", text: })
              .to_return(status: 200, body: analyze_result_for(text).to_json, headers: @headers)
          end

          assert_statsd_increment(
            "AddressValidation.elasticsearch_future_state",
            tags: ["country:US", "method:all_street_sequences", "state:unsubmitted"],
          ) do
            @datastore.fetch_street_sequences
          end
        end

        test "#fetch_street_sequences records the state of an unresolved async future at the time of the call" do
          delayed_future = Concurrent::Promises.delay { [] }
          @datastore.instance_variable_set(:@street_sequences_future, delayed_future)

          assert_statsd_increment(
            "AddressValidation.elasticsearch_future_state",
            tags: ["country:US", "method:all_street_sequences", "state:pending"],
          ) do
            @datastore.fetch_street_sequences
          end

          assert_predicate delayed_future, :fulfilled?
        end

        test "#fetch_street_sequences records the state of an resolved async future at the time of the call" do
          @datastore.street_sequences = []

          assert_statsd_increment(
            "AddressValidation.elasticsearch_future_state",
            tags: ["country:US", "method:all_street_sequences", "state:fulfilled"],
          ) do
            @datastore.fetch_street_sequences
          end
        end

        test "#fetch_street_sequences examines both address1 and address2" do
          [
            {
              input: address_320_4th_ave,
              stubs: ["4th Ave N", "Ave N"],
            },
            {
              input: address_adler_planetarium,
              stubs: ["South Lake Shore Drive"],
            },
            {
              input: address_denver_union_station,
              stubs: ["Wynkoop St"],
            },
          ].each do |scenario|
            scenario[:stubs].each do |stub|
              stub_request(:post, %r{http\://.*/test_us/_analyze})
                .with(body: { analyzer: "street_analyzer", text: stub })
                .to_return(status: 200, body: analyze_result_for(stub).to_json, headers: @headers)
            end

            datastore = AddressValidation::Es::Datastore.new(address: scenario[:input])

            sequences = datastore.fetch_street_sequences
            assert_equal scenario[:stubs].count, sequences.count
          end
        end

        test "#fetch_street_sequences returns empty sequence on error" do
          stub_request(:post, %r{http\://.*/test_us/_analyze})
            .with(body: { analyzer: "street_analyzer", text: "Main Street" })
            .to_return(status: 400)

          sequences = @datastore.fetch_street_sequences
          assert_empty sequences.first
        end

        test "#fetch_street_sequences_async returns a pending future that resolves as an array of sequences" do
          ["Main Street"].each do |text|
            stub_request(:post, %r{http\://.*/test_us/_analyze})
              .with(body: { analyzer: "street_analyzer", text: })
              .to_return(status: 200, body: analyze_result_for(text).to_json, headers: @headers)
          end

          future = @datastore.fetch_street_sequences_async
          assert_predicate future, :pending?

          sequences = future.value
          assert_predicate future, :fulfilled?
          assert sequences.is_a?(Array)
          assert_equal 1, sequences.count
          assert_equal ["main", "street"], sequences[0].tokens.map(&:value)
        end

        test "#fetch_street_sequences_async returns the same future on subsequent calls" do
          ["Main Street", "123 Main Street"].each do |text|
            stub_request(:post, %r{http\://.*/test_us/_analyze})
              .with(body: { analyzer: "street_analyzer", text: })
              .to_return(status: 200, body: analyze_result_for(text).to_json, headers: @headers)
          end

          future = @datastore.fetch_street_sequences_async

          assert_same future, @datastore.fetch_street_sequences_async
          future.wait # need to wait for the http request to be made before exiting the test
        end

        test "#fetch_street_sequences_async returns a fulfilled future if called after #street_sequences=" do
          sequences = []
          @datastore.street_sequences = sequences
          future = @datastore.fetch_street_sequences_async
          assert_predicate future, :fulfilled?

          assert_same sequences, future.value
        end

        test "#fetch_street_sequences_async measures the future's queuing time" do
          ["Main Street", "123 Main Street"].each do |text|
            stub_request(:post, %r{http\://.*/test_us/_analyze})
              .with(body: { analyzer: "street_analyzer", text: })
              .to_return(status: 200, body: analyze_result_for(text).to_json, headers: @headers)
          end

          assert_statsd_distribution(
            "AddressValidation.elasticsearch_future_queue_time",
            tags: ["country:US", "method:all_street_sequences"],
          ) do
            @datastore.fetch_street_sequences_async.wait
          end
        end

        test "#fetch_street_sequences returns result of async future if called after #fetch_street_sequences_async" do
          ["Main Street"].each do |text|
            stub_request(:post, %r{http\://.*/test_us/_analyze})
              .with(body: { analyzer: "street_analyzer", text: })
              .to_return(status: 200, body: analyze_result_for(text).to_json, headers: @headers)
          end

          future = @datastore.fetch_street_sequences_async
          assert_predicate future, :pending?

          sequences = @datastore.fetch_street_sequences

          assert_predicate future, :fulfilled?
          assert_same sequences, future.value
          assert_requested(:post, %r{http\://.*/test_us/_analyze}, times: 1)
        end

        test "#fetch_full_address_candidates returns array of candidates for country w/o normalized components set" do
          stub_request(:post, %r{http\://.*/test_us/_search})
            .to_return(status: 200, body: full_address_results.to_json, headers: @headers)

          CountryProfileValidationSubset.any_instance.stubs(:normalized_components).returns([])

          candidates = @datastore.fetch_full_address_candidates
          assert_equal candidates.size, 2
          assert_instance_of Candidate, candidates[0]

          # components and component sequences
          ca_sequences = sequences(["california"])
          region1_component = candidates[0].component(:region1)
          assert_equal "California", region1_component.value
          assert_sequence_array_equality ca_sequences, region1_component.sequences

          sf_sequences = sequences(["san", "francisco"])
          city_component = candidates[0].component(:city)
          assert_sequence_array_equality sf_sequences, city_component.sequences
        end

        test "#fetch_full_address_candidates returns array of candidates for country w/ normalized components set" do
          stub_request(:post, %r{http\://.*/test_us/_search})
            .to_return(status: 200, body: full_address_results.to_json, headers: @headers)

          stub_request(:post, %r{http\://.*/test_us/_mtermvectors})
            .to_return(status: 200, body: term_vectors_results.to_json, headers: @headers)

          CountryProfileValidationSubset.any_instance.stubs(:normalized_components).returns([
            "city",
            "street",
          ])

          candidates = @datastore.fetch_full_address_candidates
          assert_equal candidates.size, 2
          assert_instance_of Candidate, candidates[0]

          ca_sequences = sequences(["california"])
          normalized_city_sequences = sequences(["foo", "francisco"])
          [
            [ca_sequences, normalized_city_sequences, sequences(["bar", "st"])],
            [ca_sequences, normalized_city_sequences, sequences(["baz", "st"])],
          ].each_with_index do |expected_sequences, i|
            candidate = candidates[i]

            # not one of normalized components
            region1_component = candidate.component(:region1)
            assert_equal "California", region1_component.value
            assert_sequence_array_equality expected_sequences[0], region1_component.sequences
            # normalized components
            assert_sequence_array_equality expected_sequences[1], candidate.component(:city).sequences
            assert_sequence_array_equality expected_sequences[2], candidate.component(:street).sequences
          end
        end

        test "#fetch_full_address_candidates returns empty on error" do
          stub_request(:post, %r{http\://.*/test_us/_search})
            .to_return(status: 400, body: full_address_results.to_json, headers: @headers)

          candidates = @datastore.fetch_full_address_candidates
          assert_empty candidates
        end

        test "#fetch_full_address_candidates measures the time to retrieve candidates" do
          stub_request(:post, %r{http\://.*/test_us/_search})
            .to_return(status: 200, body: full_address_results.to_json, headers: @headers)

          assert_statsd_distribution(
            "AddressValidation.elasticsearch_request_time_dist",
            tags: ["country:US", "method:full_address_candidates"],
          ) do
            @datastore.fetch_full_address_candidates
          end
        end

        test "#fetch_full_address_candidates measures the time to retrieve term vectors" do
          stub_request(:post, %r{http\://.*/test_us/_search})
            .to_return(status: 200, body: full_address_results.to_json, headers: @headers)

          stub_request(:post, %r{http\://.*/test_us/_mtermvectors})
            .to_return(status: 200, body: term_vectors_results.to_json, headers: @headers)

          CountryProfileValidationSubset.any_instance.stubs(:normalized_components).returns(["city"])

          assert_statsd_distribution(
            "AddressValidation.elasticsearch_request_time_dist",
            tags: ["country:US", "method:term_vectors"],
          ) do
            @datastore.fetch_full_address_candidates
          end
        end

        test "#fetch_full_address_candidates does not call ES for the same query" do
          stub_request(:post, %r{http\://.*/test_us/_search})
            .to_return(status: 200, body: full_address_results.to_json, headers: @headers)

          @datastore.fetch_full_address_candidates

          assert_requested(:post, %r{http\://.*/test_us/_search}, times: 1)
        end

        test "#fetch_full_address_candidates does not call ES for the same query even when there is no response" do
          stub_request(:post, %r{http\://.*/test_us/_search})
            .to_return(status: 200, body: { "hits": { "hits": [] } }.to_json, headers: @headers)

          assert_equal [], @datastore.fetch_full_address_candidates
          assert_equal [], @datastore.fetch_full_address_candidates

          assert_requested(:post, %r{http\://.*/test_us/_search}, times: 1)
        end

        test "#validation_response wraps ES array response as a single hash " do
          stub_request(:post, %r{http\://.*/test_us/_search})
            .to_return(status: 200, body: full_address_results.to_json, headers: @headers)

          expected = {
            body: full_address_results.dig(:hits, :hits).map(&:deep_stringify_keys),
          }

          assert_equal expected, @datastore.validation_response

          assert_requested(:post, %r{http\://.*/test_us/_search}, times: 1)
        end

        private

        def analyze_query_results
          {
            "tokens": [
              {
                "token": "san",
                "start_offset": 0,
                "end_offset": 3,
                "type": "<ALPHANUM>",
                "position": 0,
              },
              {
                "token": "francisco",
                "start_offset": 4,
                "end_offset": 13,
                "type": "<ALPHANUM>",
                "position": 1,
              },
            ],
          }
        end

        sig { params(text: String).returns(T::Hash[Symbol, T.untyped]) }
        def analyze_result_for(text)
          result = {
            "320" => {
              "tokens": [
                { "token": "320", "start_offset": 0, "end_offset": 3, "type": "<ALPHANUM>", "position": 0 },
              ],
            },
            "4th Ave N" => {
              "tokens": [
                { "token": "4th", "start_offset": 0, "end_offset": 3, "type": "<ALPHANUM>", "position": 0 },
                { "token": "ave", "start_offset": 4, "end_offset": 7, "type": "SYNONYM", "position": 1 },
                { "token": "avenue", "start_offset": 4, "end_offset": 7, "type": "SYNONYM", "position": 1 },
                { "token": "n", "start_offset": 8, "end_offset": 9, "type": "SYNONYM", "position": 2 },
                { "token": "north", "start_offset": 8, "end_offset": 9, "type": "SYNONYM", "position": 2 },
              ],
            },
            "4th Ave" => {
              "tokens": [
                { "token": "4th", "start_offset": 0, "end_offset": 3, "type": "<ALPHANUM>", "position": 0 },
                { "token": "ave", "start_offset": 4, "end_offset": 7, "type": "SYNONYM", "position": 1 },
                { "token": "avenue", "start_offset": 4, "end_offset": 7, "type": "SYNONYM", "position": 1 },
              ],
            },
            "Ave N" => {
              "tokens": [
                { "token": "ave", "start_offset": 0, "end_offset": 3, "type": "SYNONYM", "position": 0 },
                { "token": "avenue", "start_offset": 0, "end_offset": 3, "type": "SYNONYM", "position": 0 },
                { "token": "n", "start_offset": 4, "end_offset": 5, "type": "SYNONYM", "position": 1 },
                { "token": "north", "start_offset": 4, "end_offset": 5, "type": "SYNONYM", "position": 1 },
              ],
            },
            "th Ave N" => {
              "tokens": [
                { "token": "th", "start_offset": 0, "end_offset": 2, "type": "<ALPHANUM>", "position": 0 },
                { "token": "avenue", "start_offset": 3, "end_offset": 6, "type": "SYNONYM", "position": 1 },
                { "token": "avenu", "start_offset": 3, "end_offset": 6, "type": "SYNONYM", "position": 1 },
                { "token": "aven", "start_offset": 3, "end_offset": 6, "type": "SYNONYM", "position": 1 },
                { "token": "av", "start_offset": 3, "end_offset": 6, "type": "SYNONYM", "position": 1 },
                { "token": "avenida", "start_offset": 3, "end_offset": 6, "type": "SYNONYM", "position": 1 },
                { "token": "ave", "start_offset": 3, "end_offset": 6, "type": "<ALPHANUM>", "position": 1 },
                { "token": "north", "start_offset": 7, "end_offset": 8, "type": "SYNONYM", "position": 2 },
                { "token": "n", "start_offset": 7, "end_offset": 8, "type": "<ALPHANUM>", "position": 2 },
              ],
            },
            "th Ave" => {
              "tokens": [
                { "token": "th", "start_offset": 0, "end_offset": 2, "type": "<ALPHANUM>", "position": 0 },
                { "token": "avenue", "start_offset": 3, "end_offset": 6, "type": "SYNONYM", "position": 1 },
                { "token": "avenu", "start_offset": 3, "end_offset": 6, "type": "SYNONYM", "position": 1 },
                { "token": "aven", "start_offset": 3, "end_offset": 6, "type": "SYNONYM", "position": 1 },
                { "token": "av", "start_offset": 3, "end_offset": 6, "type": "SYNONYM", "position": 1 },
                { "token": "avenida", "start_offset": 3, "end_offset": 6, "type": "SYNONYM", "position": 1 },
                { "token": "ave", "start_offset": 3, "end_offset": 6, "type": "<ALPHANUM>", "position": 1 },
              ],
            },
            "Main Street" => {
              "tokens": [
                { "token": "main", "start_offset": 0, "end_offset": 4, "type": "<ALPHANUM>", "position": 0 },
                { "token": "street", "start_offset": 5, "end_offset": 11, "type": "<ALPHANUM>", "position": 1 },
              ],
            },
            "123 Main Street" => {
              "tokens": [
                { "token": "123", "start_offset": 0, "end_offset": 3, "type": "<NUM>", "position": 0 },
                { "token": "main", "start_offset": 4, "end_offset": 8, "type": "<ALPHANUM>", "position": 1 },
                { "token": "street", "start_offset": 9, "end_offset": 15, "type": "<ALPHANUM>", "position": 2 },
              ],
            },
            "Haupt strasse" => {
              "tokens": [
                { "token": "haupt", "start_offset": 0, "end_offset": 5, "type": "<ALPHANUM>", "position": 0 },
                { "token": "strasse", "start_offset": 6, "end_offset": 13, "type": "<ALPHANUM>", "position": 1 },
              ],
            },
            "Adler Planetarium" => {
              "tokens": [
                { "token": "adler", "start_offset": 0, "end_offset": 5, "type": "<ALPHANUM>", "position": 0 },
                { "token": "planetarium", "start_offset": 6, "end_offset": 17, "type": "<ALPHANUM>", "position": 1 },
              ],
            },
            "South Lake Shore Drive" => {
              "tokens": [
                { "token": "south", "start_offset": 0, "end_offset": 5, "type": "<ALPHANUM>", "position": 0 },
                { "token": "lake", "start_offset": 6, "end_offset": 10, "type": "<ALPHANUM>", "position": 1 },
                { "token": "shore", "start_offset": 11, "end_offset": 16, "type": "<ALPHANUM>", "position": 2 },
                { "token": "drive", "start_offset": 17, "end_offset": 22, "type": "<ALPHANUM>", "position": 3 },
              ],
            },
            "1300 South Lake Shore Drive" => {
              "tokens": [
                { "token": "1300", "start_offset": 0, "end_offset": 4, "type": "<NUM>", "position": 0 },
                { "token": "south", "start_offset": 5, "end_offset": 10, "type": "<ALPHANUM>", "position": 1 },
                { "token": "lake", "start_offset": 11, "end_offset": 15, "type": "<ALPHANUM>", "position": 2 },
                { "token": "shore", "start_offset": 16, "end_offset": 21, "type": "<ALPHANUM>", "position": 3 },
                { "token": "drive", "start_offset": 22, "end_offset": 27, "type": "<ALPHANUM>", "position": 4 },
              ],
            },
            "1701" => {
              "tokens": [
                { "token": "1701", "start_offset": 0, "end_offset": 4, "type": "<ALPHANUM>", "position": 0 },
              ],
            },
            "Wynkoop St" => {
              "tokens": [
                { "token": "wynkoop", "start_offset": 0, "end_offset": 7, "type": "<ALPHANUM>", "position": 0 },
                { "token": "st", "start_offset": 8, "end_offset": 10, "type": "SYNONYM", "position": 1 },
                { "token": "street", "start_offset": 8, "end_offset": 10, "type": "SYNONYM", "position": 1 },
                { "token": "saint", "start_offset": 8, "end_offset": 10, "type": "SYNONYM", "position": 1 },
              ],
            },
            "po box" => {
              "tokens": [
                { "token": "po", "start_offset": 0, "end_offset": 2, "type": "<ALPHANUM>", "position": 0 },
                { "token": "box", "start_offset": 3, "end_offset": 6, "type": "<ALPHANUM>", "position": 1 },
              ],
            },
          }[text]

          raise "Test is incorrect:  need definition of analyze result for #{text.inspect}." if result.blank?

          result
        end

        def address
          build_address(
            address1: "123 Main Street",
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
        end

        def address_320_4th_ave
          build_address(
            address1: "320",
            address2: "4th Ave N",
            city: "Algona",
            province_code: "WA",
            zip: "98001",
            country_code: "US",
          )
        end

        def address_adler_planetarium
          build_address(
            address1: "Adler Planetarium",
            address2: "1300 South Lake Shore Drive",
            city: "Chicago",
            province_code: "IL",
            zip: "60605-2403",
            country_code: "US",
          )
        end

        def address_denver_union_station
          build_address(
            address1: "1701",
            address2: "Wynkoop St",
            city: "Denver",
            province_code: "CO",
            zip: "80202",
            country_code: "US",
          )
        end

        def address_po_box
          build_address(
            address1: "PO BOX 111",
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
        end

        def full_address_results
          {
            "hits": {
              "hits": [
                {
                  "_index": "us.1",
                  "_type": "_doc",
                  "_id": "712676",
                  "_score": 22.564898,
                  "_source": {
                    "locale": "EN",
                    "country_code": "US",
                    "province_code": "CA",
                    "region1": "California",
                    "region2": "San Francisco",
                    "region3": nil,
                    "region4": nil,
                    "city": ["San Francisco"],
                    "suburb": nil,
                    "zip": "94102",
                    "street": "Birch Street",
                    "building_name": nil,
                    "latitude": 37.778,
                    "longitude": -122.426,
                  },
                },
                {
                  "_index": "us.1",
                  "_type": "_doc",
                  "_id": "712996",
                  "_score": 22.564898,
                  "_source": {
                    "locale": "EN",
                    "country_code": "US",
                    "province_code": "CA",
                    "region1": "California",
                    "region2": "San Francisco",
                    "region3": nil,
                    "region4": nil,
                    "city": ["San Francisco"],
                    "suburb": nil,
                    "zip": "94102",
                    "street": "Cyril Magnin Street",
                    "building_name": nil,
                    "latitude": 37.7852,
                    "longitude": -122.409,
                  },
                },
              ],
            },
          }
        end

        def term_vectors_results
          {
            "docs": [
              {
                "_index": "us.1",
                "_id": "712676",
                "_version": 1,
                "found": true,
                "took": 6,
                "term_vectors": {
                  "city": {
                    "terms": {
                      "francisco": {
                        "term_freq": 1,
                        "tokens": [
                          {
                            "position": 1,
                            "start_offset": 4,
                            "end_offset": 13,
                          },
                        ],
                      },
                      "foo": {
                        "term_freq": 1,
                        "tokens": [
                          {
                            "position": 0,
                            "start_offset": 0,
                            "end_offset": 3,
                          },
                        ],
                      },
                    },
                  },
                  "street": {
                    "terms": {
                      "bar": {
                        "term_freq": 1,
                        "tokens": [
                          {
                            "position": 0,
                            "start_offset": 0,
                            "end_offset": 3,
                          },
                        ],
                      },
                      "st": {
                        "term_freq": 1,
                        "tokens": [
                          {
                            "position": 1,
                            "start_offset": 4,
                            "end_offset": 6,
                          },
                        ],
                      },
                    },
                  },
                },
              },
              {
                "_index": "us.1",
                "_id": "712996",
                "_version": 1,
                "found": true,
                "took": 11,
                "term_vectors": {
                  "city": {
                    "terms": {
                      "francisco": {
                        "term_freq": 1,
                        "tokens": [
                          {
                            "position": 1,
                            "start_offset": 4,
                            "end_offset": 13,
                          },
                        ],
                      },
                      "foo": {
                        "term_freq": 1,
                        "tokens": [
                          {
                            "position": 0,
                            "start_offset": 0,
                            "end_offset": 3,
                          },
                        ],
                      },
                    },
                  },
                  "street": {
                    "terms": {
                      "baz": {
                        "term_freq": 1,
                        "tokens": [
                          {
                            "position": 0,
                            "start_offset": 0,
                            "end_offset": 3,
                          },
                        ],
                      },
                      "st": {
                        "term_freq": 1,
                        "tokens": [
                          {
                            "position": 1,
                            "start_offset": 4,
                            "end_offset": 6,
                          },
                        ],
                      },
                    },
                  },
                },
              },
            ],
          }
        end
      end
    end
  end
end
