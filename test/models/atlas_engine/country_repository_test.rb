# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  class CountryRepositoryTest < ActiveSupport::TestCase
    include AddressValidation::AddressValidationTestHelper

    setup do
      @repo = CountryRepository.new(
        country_code: "US",
        repository_class: Elasticsearch::Repository,
        index_configuration: IndexConfigurationFactory.new(country_code: "US").index_configuration,
      )
      @post_address = {
        id: "123",
        locale: "EN",
        country_code: "CA",
        province_code: "AB",
        region1: "Alberta",
        region2: "Athabasca",
        region3: nil,
        region4: nil,
        city: ["Athabasca"],
        suburb: nil,
        zip: "T9S 1N5",
        street: "28 Street",
        building_name: nil,
        building_and_unit_ranges: {
          "(A1..A9)/2" => { "APT" => ["(1..4)/1"] },
          "(A12..A16)/2" => { "APT" => ["(1..4)/1"] },
          "(1011-10..1011-15)/1" => {},
        },
        latitude: 54.713363,
        longitude: -113.248051,
      }
    end

    test "#initialize requires locale for multi-locale country" do
      profile_attributes = {
        "id" => "CH_DE",
        "validation" => {
          "index_locales" => ["de", "fr"],
        },
      }
      CountryProfile.expects(:for).with("ch", "de").returns(CountryProfile.new(profile_attributes))

      stub_request(:get, %r{http\://.*/test_ch_de/_doc/123})
        .to_return(status: 200, body: document_result.to_json, headers: { "Content-Type" => "application/json" })

      repo = CountryRepository.new(
        country_code: "CH",
        repository_class: Elasticsearch::Repository,
        locale: "de",
      )

      response = repo.find(123)
      assert_equal document_result[:_source].stringify_keys, response
    end

    test "#initialize raises error if locale is not provided for multi-locale country" do
      assert_raises(ArgumentError) do
        CountryRepository.new(
          country_code: "CH",
          repository_class: Elasticsearch::Repository,
        )
      end
    end

    test "#initialize ignores locale if country is not multi-locale" do
      stub_request(:get, %r{http\://.*/test_us/_doc/123})
        .to_return(status: 200, body: document_result.to_json, headers: { "Content-Type" => "application/json" })

      repo = CountryRepository.new(
        country_code: "US",
        repository_class: Elasticsearch::Repository,
        locale: "en",
      )

      response = repo.find(123)
      assert_equal document_result[:_source].stringify_keys, response
    end

    test "#initialize uses the country code as the index name when index param is blank" do
      stub_request(:get, %r{http\://.*/test_us/_doc/123})
        .to_return(status: 200, body: document_result.to_json, headers: { "Content-Type" => "application/json" })

      repo = CountryRepository.new(
        country_code: "US",
        repository_class: Elasticsearch::Repository,
      )

      response = repo.find(123)
      assert_equal document_result[:_source].stringify_keys, response
    end

    test "#record_source persists non-nil fields from the post_address without modification" do
      mock_mapped_data = {
        id: "123",
        locale: "EN",
        country_code: "CA",
        province_code: nil,
      }

      AddressValidation::Es::DataMappers::DefaultDataMapper.any_instance.stubs(:map_data).returns(mock_mapped_data)
      persisted_document = @repo.record_source(@post_address)

      expected_document = {
        id: "123",
        locale: "EN",
        country_code: "CA",
      }

      assert_equal expected_document, persisted_document
    end

    test "search returns results" do
      stub_request(:post, %r{http\://.*/test_us/_search})
        .with(body: "{\"query\":{\"match_all\":{}}}")
        .to_return(status: 200, body: full_address_results.to_json, headers: { "Content-Type" => "application/json" })

      mock_query = { query: { match_all: {} } }

      response = @repo.search(mock_query)
      assert_equal full_address_results[:hits][:hits].map(&:deep_stringify_keys), response
    end

    test "find returns the record by id" do
      stub_request(:get, %r{http\://.*/test_us/_doc/123})
        .to_return(status: 200, body: document_result.to_json, headers: { "Content-Type" => "application/json" })

      response = @repo.find(123)
      assert_equal document_result[:_source].stringify_keys, response
    end

    test "analyze returns the analysis for the query" do
      analyze_result =
        {
          "tokens": [
            { "token": "4th", "start_offset": 0, "end_offset": 3, "type": "<ALPHANUM>", "position": 0 },
            { "token": "ave", "start_offset": 4, "end_offset": 7, "type": "SYNONYM", "position": 1 },
            { "token": "avenue", "start_offset": 4, "end_offset": 7, "type": "SYNONYM", "position": 1 },
            { "token": "n", "start_offset": 8, "end_offset": 9, "type": "SYNONYM", "position": 2 },
            { "token": "north", "start_offset": 8, "end_offset": 9, "type": "SYNONYM", "position": 2 },
          ],
        }

      mock_query = { analyzer: "street_analyzer", text: "4th Ave N" }

      stub_request(:post, %r{http\://.*/test_us/_analyze})
        .with(body: mock_query)
        .to_return(status: 200, body: analyze_result.to_json, headers: { "Content-Type" => "application/json" })

      response = @repo.analyze(mock_query)

      assert_equal analyze_result[:tokens].map(&:stringify_keys), response
    end

    test "term_vectors returns the term vectors for the query" do
      mock_query = {
        ids: 123,
        parameters: {
          fields: ["city", "street"],
          field_statistics: false,
        },
      }

      stub_request(:post, %r{http\://.*/test_us/_mtermvectors})
        .with(body: mock_query)
        .to_return(status: 200, body: term_vectors_results.to_json, headers: { "Content-Type" => "application/json" })

      assert_equal term_vectors_results[:docs].map(&:deep_stringify_keys), @repo.term_vectors(mock_query)
    end

    private

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

    def document_result
      {
        "_index": "us",
        "_id": "1",
        "_version": 1,
        "_seq_no": 0,
        "_primary_term": 1,
        "found": true,
        "_source": {
          "locale": "EN",
          "country_code": "US",
          "province_code": "NY",
          "region1": "New York",
          "region2": "New York",
          "city": [
            "New York",
            "Prince",
          ],
          "zip": "10012",
          "street": "Greene St",
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
