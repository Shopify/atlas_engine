# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Es
      module Validators
        class FullAddressTest < ActiveSupport::TestCase
          include AddressValidationTestHelper
          include StatsD::Instrument::Assertions

          setup do
            @klass = AddressValidation::Es::Validators::FullAddress
            @address = address
            @session = AddressValidation::Session.new(address: @address)
            # prime datastore cache to avoid calls to the DB in Datastore
            @datastore = AddressValidation::Es::Datastore.new(address: @address)
            @datastore.city_sequence = Token::Sequence.from_string(@address.city)
            @datastore.street_sequences = [
              Token::Sequence.from_string(@address.address1),
            ]
          end

          test "does not modify the result if there are existing error concerns related to other address fields" do
            AddressValidation::Es::Datastore.expects(:new).never

            [:country, :province, :zip, :city, :address1, :address2].each do |scope|
              result = AddressValidation::Result.new
              concern = result.add_concern(
                code: :i_r_teh_winnar,
                type: Concern::TYPES[:error],
                type_level: 1,
                suggestion_ids: [],
                field_names: [scope],
                message: "I R teH winn4rrr !!11!",
              )

              full_address = @klass.new(address: @address, result: result)
              full_address.session = @session
              full_address.validate
              assert_equal [concern], result.concerns
            end
          end

          test "does not modify the result if there are addrees1 or address2 tokens exceed max count" do
            AddressValidation::Es::Datastore.expects(:new).never

            [:address1, :address2].each do |scope|
              result = AddressValidation::Result.new
              concern = result.add_concern(
                code: "#{scope}_contains_too_many_words".to_sym,
                type: Concern::TYPES[:warning],
                type_level: 1,
                suggestion_ids: [],
                field_names: [scope],
                message: "I R teH winn4rrr !!11!",
              )

              full_address = @klass.new(address: @address, result: result)
              full_address.session = @session
              full_address.validate
              assert_equal [concern], result.concerns
            end
          end

          test "proceeds with full address validation when there are only warning-level concerns" do
            @datastore.candidates = [candidate] # candidate is a perfect match.
            AddressValidation::Es::Datastore.expects(:new).returns(@datastore)

            result = AddressValidation::Result.new
            result.add_concern(
              field_names: [:address1, :country],
              message: :missing_building_number.to_s.humanize,
              code: :missing_building_number,
              type: Concern::TYPES[:warning],
              type_level: 1,
              suggestion_ids: [],
            )

            AddressValidation::Validators::FullAddress::CandidateResult.any_instance.expects(:update_result)
            full_address = @klass.new(address: @address, result: result)
            full_address.validate
            assert_equal 1, result.concerns.size
            assert_equal :missing_building_number, result.concerns.first.code
          end

          test "does not query es if the address is not supported" do
            @address = address(
              country_code: "GG",
              address1: "1 La Clôture de Bas",
              zip: "GY9 1SD",
              city: "Sark", # Sark is not supported in GG
            )

            result = AddressValidation::Result.new

            AddressValidation::Es::Datastore.expects(:new).never

            @klass.new(address: @address, result: result).validate
          end

          test "returns address_unknown if the full address query produces no results" do
            @datastore.candidates = []
            AddressValidation::Es::Datastore.expects(:new).returns(@datastore)

            result = AddressValidation::Result.new

            full_address = @klass.new(address: @address, result: result)
            full_address.validate

            assert_equal 1, result.concerns.size
            assert_equal :address_unknown, result.concerns.first.code
          end

          test "picks the candidate having the best merged comparison compared to the address" do
            @datastore.candidates = [
              candidate(city: "San Fransauceco"), # close
              candidate(city: "Man Francisco"), # best match, off by one letter on one field
              candidate(city: "Saint Fransauceco"),
            ]
            AddressValidation::Es::Datastore.expects(:new).returns(@datastore)

            result = AddressValidation::Result.new
            ActiveSupport::Notifications.expects(:instrument)

            full_address = @klass.new(address: @address, result: result)
            full_address.validate

            assert_equal 1, result.concerns.size
            assert_equal :city_inconsistent, result.concerns.first.code
            assert_equal "Man Francisco", result.suggestions.first.attributes[:city]
          end

          test "picks the best candidate for a multi-locale country" do
            @address = address(address1: "Mövenweg", zip: "8597", country_code: "CH", city: "Brn", province_code: "")
            ch_de_datastore = AddressValidation::Es::Datastore.new(address: @address, locale: "de")
            ch_fr_datastore = AddressValidation::Es::Datastore.new(address: @address, locale: "fr")
            ch_it_datastore = AddressValidation::Es::Datastore.new(address: @address, locale: "it")

            ch_de_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            ch_de_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]

            ch_fr_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            ch_fr_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]

            ch_it_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            ch_it_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]

            ch_fr_datastore.candidates = [
              candidate(city: "Zurich"),
              candidate(city: "Ouster"),
              candidate(city: "Berne"), # best match for french, off by 2
            ]
            ch_it_datastore.candidates = [
              candidate(city: "Zurigo"),
              candidate(city: "Austero"),
              candidate(city: "Berna"), # best match for italian, off by 2
            ]
            ch_de_datastore.candidates = [
              candidate(city: "Zurich"),
              candidate(city: "Uster"),
              candidate(city: "Bern"), # best overall match, off by 1
            ]

            AddressValidation::Es::Datastore.expects(:new).with(
              address: @address,
              locale: "de",
            ).returns(ch_de_datastore)
            AddressValidation::Es::Datastore.expects(:new).with(
              address: @address,
              locale: "fr",
            ).returns(ch_fr_datastore)
            AddressValidation::Es::Datastore.expects(:new).with(
              address: @address,
              locale: "it",
            ).returns(ch_it_datastore)

            result = AddressValidation::Result.new
            ActiveSupport::Notifications.expects(:instrument)

            full_address = @klass.new(address: @address, result: result)
            full_address.validate

            assert_equal 1, result.concerns.size
            assert_equal :city_inconsistent, result.concerns.first.code
            assert_equal "Bern", result.suggestions.first.attributes[:city]
          end

          test "handles empty candidates during multi-locale best candidate selection" do
            @address = address(country_code: "CH", city: "Brn")
            ch_de_datastore = AddressValidation::Es::Datastore.new(address: @address, locale: "de")
            ch_fr_datastore = AddressValidation::Es::Datastore.new(address: @address, locale: "fr")
            ch_it_datastore = AddressValidation::Es::Datastore.new(address: @address, locale: "it")

            ch_de_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            ch_de_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]

            ch_fr_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            ch_fr_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]

            ch_it_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            ch_it_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]

            ch_fr_datastore.candidates = [
              candidate(city: "Berne"), # best match for french, off by 2
            ]
            ch_it_datastore.candidates = [
              candidate(city: "Berna"), # best match for italian, off by 2
            ]
            ch_de_datastore.candidates = [] # no candidates for german

            AddressValidation::Es::Datastore.expects(:new).with(
              address: @address,
              locale: "de",
            ).returns(ch_de_datastore)
            AddressValidation::Es::Datastore.expects(:new).with(
              address: @address,
              locale: "fr",
            ).returns(ch_fr_datastore)
            AddressValidation::Es::Datastore.expects(:new).with(
              address: @address,
              locale: "it",
            ).returns(ch_it_datastore)

            result = AddressValidation::Result.new
            ActiveSupport::Notifications.expects(:instrument)

            full_address = @klass.new(address: @address, result: result)
            full_address.validate

            assert_equal 1, result.concerns.size
            assert_equal :city_inconsistent, result.concerns.first.code
            assert_equal "Berne", result.suggestions.first.attributes[:city]
          end

          test "returns invalid_zip_and_province if province is valid and zip prefix is incompatible" do
            @address = address(zip: "84102") # invalid for California
            datastore = AddressValidation::Es::Datastore.new(address: @address)

            datastore.city_sequence = Token::Sequence.from_string(@address.city)
            datastore.street_sequences = [
              Token::Sequence.from_string(@address.address1),
            ]
            datastore.candidates = [candidate(zip: "94102")]
            AddressValidation::Es::Datastore.expects(:new).returns(datastore)

            result = AddressValidation::Result.new

            full_address = @klass.new(address: @address, result: result)
            full_address.validate

            assert_equal 1, result.concerns.size
            assert_equal :zip_invalid_for_province, result.concerns.first.code
            assert_equal "94102", result.suggestions.first.attributes[:zip]
          end

          test "atlas_engine.address_validation.validation_completed notifications event fires for nil best_candidate" do
            @datastore.candidates = [] # candidate is nil.
            result = AddressValidation::Result.new(client_request_id: "1234", origin: "https://random-url.com")

            AddressValidation::Es::Datastore.expects(:new).returns(@datastore)
            ActiveSupport::Notifications.expects(:instrument)

            full_address = @klass.new(address: @address, result: result)

            full_address.validate
          end

          private

          def address(address1: "123 Main Street", zip: "94102", country_code: "US", city: "San Francisco",
            province_code: "CA")
            build_address(
              address1: address1,
              city: city,
              province_code: province_code,
              country_code: country_code,
              zip: zip,
            )
          end

          def candidate(overrides = {})
            candidate_hash = @address.to_h.transform_keys(address1: :street).merge(overrides)
            AddressValidation::Candidate.new(id: "A", source: candidate_hash)
          end
        end
      end
    end
  end
end
