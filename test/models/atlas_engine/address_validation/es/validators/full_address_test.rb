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
            @address = address
            @candidate = candidate
          end

          test "does not modify the result if there are existing error concerns related to other address fields" do
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

              FullAddress.new(address: @address, result: result).validate

              assert_equal [concern], result.concerns
            end
          end

          test "does not modify the result if address1 or address2 tokens exceed max count" do
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

              FullAddress.new(address: @address, result: result).validate

              assert_equal [concern], result.concerns
            end
          end

          test "proceeds with full address validation when there are only warning-level concerns" do
            result = AddressValidation::Result.new
            result.add_concern(
              field_names: [:address1, :country],
              message: :missing_building_number.to_s.humanize,
              code: :missing_building_number,
              type: Concern::TYPES[:warning],
              type_level: 1,
              suggestion_ids: [],
            )

            AddressValidation::Es::CandidateSelector.any_instance.expects(:best_candidate_async).returns(
              Concurrent::Promises.future { address_comparison },
            )
            AddressValidation::Validators::FullAddress::CandidateResult.any_instance.expects(:update_result)

            FullAddress.new(address: @address, result: result).validate

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

            AddressValidation::Es::CandidateSelector.any_instance.expects(:best_candidate_async).times(0)

            FullAddress.new(address: @address, result: result).validate
          end

          test "returns address_unknown if the full address query produces no results" do
            result = AddressValidation::Result.new

            AddressValidation::Es::CandidateSelector.any_instance.expects(:best_candidate_async).returns(
              Concurrent::Promises.future { nil },
            )

            FullAddress.new(address: @address, result: result).validate

            assert_equal 1, result.concerns.size
            assert_equal :address_unknown, result.concerns.first.code
          end

          test "updates result from candidate result" do
            result = AddressValidation::Result.new

            AddressValidation::Es::CandidateSelector.any_instance.expects(:best_candidate_async).returns(
              Concurrent::Promises.future { address_comparison },
            )

            candidate_result = typed_mock(AddressValidation::Validators::FullAddress::CandidateResult)
            AddressValidation::Validators::FullAddress::CandidateResult.expects(:new)
              .returns(candidate_result)
            candidate_result.expects(:update_result).once

            FullAddress.new(address: @address, result: result).validate
          end

          test "picks the best candidate for a multi-locale country" do
            @address = address(address1: "Mövenweg", zip: "8597", country_code: "CH", city: "Brn", province_code: "")

            de_datastore = Es::Datastore.new(address: @address, locale: "de")
            de_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            de_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]
            de_datastore.candidates = [
              candidate(city: "Zurich"),
              candidate(city: "Uster"),
              candidate(city: "Bern"), # best overall match, off by 1
            ]

            fr_datastore = Es::Datastore.new(address: @address, locale: "fr")
            fr_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            fr_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]
            fr_datastore.candidates = [
              candidate(city: "Zurich"),
              candidate(city: "Ouster"),
              candidate(city: "Berne"), # best match for french, off by 2
            ]

            it_datastore = Es::Datastore.new(address: @address, locale: "it")
            it_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            it_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]
            it_datastore.candidates = [
              candidate(city: "Zurigo"),
              candidate(city: "Austero"),
              candidate(city: "Berna"), # best match for italian, off by 2
            ]

            Es::Datastore.expects(:new).with(address: @address, locale: "de").returns(de_datastore)
            Es::Datastore.expects(:new).with(address: @address, locale: "fr").returns(fr_datastore)
            Es::Datastore.expects(:new).with(address: @address, locale: "it").returns(it_datastore)

            result = AddressValidation::Result.new
            ActiveSupport::Notifications.expects(:instrument)

            FullAddress.new(address: @address, result: result).validate

            assert_equal 1, result.concerns.size
            assert_equal :city_inconsistent, result.concerns.first.code
            assert_equal "Bern", result.suggestions.first.attributes[:city]
          end

          test "handles empty candidates during multi-locale best candidate selection" do
            @address = address(country_code: "CH", city: "Brn")

            de_datastore = Es::Datastore.new(address: @address, locale: "de")
            de_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            de_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]
            de_datastore.candidates = [] # no candidates for german

            fr_datastore = Es::Datastore.new(address: @address, locale: "fr")
            fr_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            fr_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]
            fr_datastore.candidates = [
              candidate(city: "Berne"), # best match for french, off by 2
            ]

            it_datastore = Es::Datastore.new(address: @address, locale: "it")
            it_datastore.city_sequence = Token::Sequence.from_string(@address.city)
            it_datastore.street_sequences = [Token::Sequence.from_string(@address.address1)]
            it_datastore.candidates = [
              candidate(city: "Berna"), # best match for italian, off by 2
            ]

            Es::Datastore.expects(:new).with(address: @address, locale: "de").returns(de_datastore)
            Es::Datastore.expects(:new).with(address: @address, locale: "fr").returns(fr_datastore)
            Es::Datastore.expects(:new).with(address: @address, locale: "it").returns(it_datastore)

            result = AddressValidation::Result.new
            ActiveSupport::Notifications.expects(:instrument)

            FullAddress.new(address: @address, result: result).validate

            assert_equal 1, result.concerns.size
            assert_equal :city_inconsistent, result.concerns.first.code
            assert_equal "Berne", result.suggestions.first.attributes[:city]
          end

          test "atlas_engine.address_validation.validation_completed notifications event fires for nil best_candidate" do
            result = AddressValidation::Result.new(client_request_id: "1234", origin: "https://random-url.com")

            ActiveSupport::Notifications.expects(:instrument)

            AddressValidation::Es::CandidateSelector.any_instance.expects(:best_candidate_async).returns(
              Concurrent::Promises.future { nil },
            )

            FullAddress.new(address: @address, result: result).validate
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

          def address_comparison
            address_comparison = typed_mock(AddressValidation::Validators::FullAddress::AddressComparison)
            address_comparison.stubs(:address).returns(@address)
            address_comparison.stubs(:candidate).returns(@candidate)
            address_comparison
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
