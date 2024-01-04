# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    class CandidateTest < ActiveSupport::TestCase
      include AddressValidation::TokenHelper

      setup do
        @candidate = AddressValidation::Candidate.from(hit)
      end

      test "index is nil if not specified" do
        candidate = AddressValidation::Candidate.new(id: "id", source: {})
        assert_nil candidate.index
      end

      test ".from derives attributes from hit" do
        assert_equal "4529374", @candidate.id
        assert_equal "us.1", @candidate.index
      end

      test "#component returns the component object for a selected column of a hit" do
        assert_equal @candidate.component(:city).value, ["Daly City"]
        assert_equal @candidate.component(:zip).value, "94014"
      end

      test "#component returns a Component with a nil value if the component is not present in the hit" do
        component = @candidate.component(:unknown)
        assert_equal :unknown, component.name
        assert_nil component.value
        assert_empty component.sequences
      end

      test "#component inserts persistent component if source value was originally nil" do
        assert_nil @candidate.component(:region3).value
        @candidate.component(:region3).value = "Region3"
        assert_equal "Region3", @candidate.component(:region3).value
      end

      test "#components returns all the component objects for a hit if there are no specified components" do
        component_values = [
          [:locale, "EN"],
          [:country_code, "US"],
          [:province_code, "CA"],
          [:region1, "California"],
          [:region2, "San Mateo"],
          [:city_aliases, [{ "alias": "Daly City" }]],
          [:zip, "94014"],
          [:street, "Mission Circle"],
          [:latitude, 37.7062],
          [:longitude, -122.462],
          [:city, ["Daly City"]],
          [:id, "4529374"],
        ]

        result = @candidate.components.map { |key, component| [key, component.value] }
        assert_equal component_values, result
      end

      test "#components returns component objects for selected columns" do
        component_values = [
          [:locale, "EN"],
          [:province_code, "CA"],
          [:region1, "California"],
          [:region3, nil], # not present in the source hash
          [:city, ["Daly City"]],
          [:id, "4529374"],
        ]

        result = @candidate.components(:locale, :province_code, :region1, :region3, :city, :id).map do |key, component|
          [key, component.value]
        end
        assert_equal component_values, result
      end

      test "Component#first_value returns value for single value components" do
        candidate_hit = hit(city_aliases: [
          { "alias": "Los Angeles" },
          { "alias": "Fairlane Park" },
          { "alias": "Fairlane Pk" },
        ])
        candidate = AddressValidation::Candidate.from(candidate_hit)
        assert_equal "CA", candidate.component(:province_code).first_value
      end

      test "Component#first_value returns value for multi value components" do
        candidate_hit = hit(city_aliases: [
          { "alias": "Los Angeles" },
          { "alias": "Fairlane Park" },
          { "alias": "Fairlane Pk" },
        ])
        candidate = AddressValidation::Candidate.from(candidate_hit)
        assert_equal "Los Angeles", candidate.component(:city).first_value
      end

      test "Component#sequences returns empty sequences if none was assigned and the component value is nil" do
        assert_predicate @candidate.component(:region3).sequences, :empty?
      end

      test "Component#sequences returns a new token sequence parsed from the component value if none was assigned" do
        assert_sequence_array_equality sequences(["san", "mateo"]), @candidate.component(:region2).sequences
      end

      test "Component#sequences returns a new token sequence parsed from the component value that has multiple values" do
        candidate_hit = hit(city_aliases: [
          { "alias": "Los Angeles" },
          { "alias": "Fairlane Park" },
          { "alias": "Fairlane Pk" },
        ])
        candidate = AddressValidation::Candidate.from(candidate_hit)
        city_sequences = candidate.component(:city).sequences

        assert_sequence_array_equality sequences(["los", "angeles"], ["fairlane", "park"], ["fairlane", "pk"]),
          city_sequences
      end

      test "Component#sequences returns a previously assigned sequence" do
        expected_sequence = sequences(["some"], ["sequence"])
        @candidate.component(:region3).sequences = expected_sequence
        assert_equal expected_sequence, @candidate.component(:region3).sequences
      end

      test "Component#serialize returns non-array values as strings" do
        assert_equal "37.7062", @candidate.component(:latitude).serialize
        assert_equal "", @candidate.component(:building_name).serialize
        assert_equal "94014", @candidate.component(:zip).serialize
      end

      test "Component#serialize returns array values as a bracketed list of values" do
        candidate_hit = hit(city_aliases: [
          { "alias": "Los Angeles" },
          { "alias": "Fairlane Park" },
          { "alias": "Fairlane Pk" },
        ])
        candidate = AddressValidation::Candidate.from(candidate_hit)
        assert_equal "[Los Angeles,Fairlane Park,Fairlane Pk]", candidate.component(:city).serialize
      end

      test "#serialize returns province/region2/region3/region4/zip/city/suburb/street as comma-delimited string" do
        candidate_hit = hit(region3: "Region3", region4: "Region4", suburb: "Suburb")
        candidate = AddressValidation::Candidate.from(candidate_hit)

        assert_equal "EN,CA,San Mateo,Region3,Region4,94014,[Daly City],Suburb,Mission Circle", candidate.serialize
      end

      test "#serialize leaves nil components as empty values in string" do
        assert_equal "EN,CA,San Mateo,,,94014,[Daly City],,Mission Circle", @candidate.serialize
      end

      test "#describes_po_box? is true when the street is a po box" do
        candidate_hit = hit(street: "po box")
        candidate = AddressValidation::Candidate.from(candidate_hit)
        assert candidate.describes_po_box?
      end

      test "#describes_po_box? is false when the street is not a po box" do
        assert_not @candidate.describes_po_box?
      end

      test "#describes_po_box? is false when the street is not defined" do
        candidate_hit = hit(street: nil)
        candidate = AddressValidation::Candidate.from(candidate_hit)
        assert_not candidate.describes_po_box?
      end

      test "#describes_general_delivery? is false when the street is not general_delivery" do
        assert_not @candidate.describes_general_delivery?
      end

      test "#describes_general_delivery? is true when the street is general_delivery" do
        candidate_hit = hit(street: "general delivery")
        candidate = AddressValidation::Candidate.from(candidate_hit)
        assert candidate.describes_general_delivery?
      end

      test "#describes_general_delivery? is false when the street is not defined" do
        candidate_hit = hit(street: nil)
        candidate = AddressValidation::Candidate.from(candidate_hit)
        assert_not candidate.describes_general_delivery?
      end

      private

      def hit(overrides = {})
        {
          "_index" => "us.1",
          "_type" => "_doc",
          "_id" => "4529374",
          "_score" => 1.0,
          "_source" => {
            "locale" => "EN",
            "country_code" => "US",
            "province_code" => "CA",
            "region1" => "California",
            "region2" => "San Mateo",
            "city_aliases" => [{ "alias": "Daly City" }],
            "zip" => "94014",
            "street" => "Mission Circle",
            "latitude" => 37.7062,
            "longitude" => -122.462,
          }.merge(overrides.transform_keys(&:to_s)),
        }
      end
    end
  end
end
