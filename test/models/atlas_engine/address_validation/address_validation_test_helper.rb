# typed: false
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module AddressValidationTestHelper
      def build_address_obj(address1: "", address2: "", city: "", province_code: "", zip: "", country_code: "",
        phone: "")
        AddressValidation::Address.new(
          {
            address1: address1,
            address2: address2,
            city: city,
            province_code: province_code,
            zip: zip,
            country_code: country_code,
            phone: phone,
          },
        )
      end

      def build_address(address1: "", address2: "", city: "", province_code: "", zip: "", country_code: "",
        phone: "")
        # To accurately test how our code will behave when running in production, we need to pass the
        # address as a GraphQL AddressInput object, so that we will be operating within the constraints that
        # it imposes.
        Types::AddressValidation::AddressInput.from_hash(
          {
            address1: address1,
            address2: address2,
            city: city,
            province_code: province_code,
            zip: zip,
            country_code: country_code,
            phone: phone,
          },
        )
      end

      def expected_address_query(suffix)
        JSON.parse(File.read("test/fixtures/atlas_engine/address_validation/address_query_#{suffix}.json"))
      end

      def filled_result
        fields = [
          Field.new(name: "address1", value: "777 Pasifik Blvd"),
          Field.new(name: "address2", value: nil),
          Field.new(name: "city", value: "Toronto"),
          Field.new(name: "country_code", value: "CA"),
          Field.new(name: "province_code", value: "BC"),
          Field.new(name: "zip", value: "V6B 4Y8"),
          Field.new(name: "phone", value: "6048676367"),
        ]

        suggestion = Suggestion.new(
          address1: "777 Pacific Blvd",
          address2: "",
          city: "Vancouver",
          province_code: "BC",
          zip: "V6B 4Y8",
          country_code: "CA",
        )
        first_concern = AddressValidation::Concern.new(
          field_names: [:city, :zip, :country],
          code: :city_inconsistent,
          message: "Enter a valid city for V6B 4Y8",
          type: AddressValidation::Concern::TYPES[:error],
          type_level: 3,
          suggestion_ids: [suggestion.id],
        )
        second_concern = AddressValidation::Concern.new(
          field_names: [:address1, :address2, :zip, :country],
          code: :street_inconsistent,
          message: "Street unknown for zip",
          type: AddressValidation::Concern::TYPES[:error],
          type_level: 3,
          suggestion_ids: [],
        )
        validation_scope = ["country_code", "province_code", "zip", "city", "address1"]
        errors = []
        candidate = "BC,V6B 4Y8,Vancouver,777 Pacific Blvd"
        Result.new(
          client_request_id: "hello yes",
          fields: fields,
          suggestions: [suggestion],
          concerns: [first_concern, second_concern],
          validation_scope: validation_scope,
          errors: errors,
          candidate: candidate,
          matching_strategy: "es_street",
        )
      end
    end
  end
end
