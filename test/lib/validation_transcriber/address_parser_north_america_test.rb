# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module ValidationTranscriber
    class AddressParserNorthAmericaTest < ActiveSupport::TestCase
      include AddressValidation::AddressValidationTestHelper

      test "empty address lines" do
        [
          [:us, "", "", []],
          [:us, nil, nil, []],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "neither building number nor unit" do
        [
          [:us, "Pitkin Iron Road", nil, []],
          [:us, "1st Street", nil, []],
          [:us, nil, "4th Street", []],
          [:us, nil, "Louis 14th", []],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "street names that look like ordinal suffixes are only recognized when surrounded by whitespace" do
        [
          [:us, "123 4th Street", nil, [{ building_num: "123", street: "4th Street" }]],
          [
            :us,
            "123 4 th Street",
            nil,
            [
              { building_num: "123", street: "4 th Street" },
              { building_name: "123", building_num: "4", street: "th Street" },
            ],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "building numbers with neither units nor directionals" do
        [
          [:us, "11925 Ring Road", nil, [{ building_num: "11925", street: "Ring Road" }]],
          [:us, "3400", "Austin Lane", [{ building_num: "3400", street: "Austin Lane" }]],
          [:us, nil, "15641 Sr 327", [{ building_num: "15641", street: "Sr 327" }]],
          [:us, "2721 Eado Edge Court,", nil, [{ building_num: "2721", street: "Eado Edge Court" }]],
          [
            :us,
            "121 1st Street",
            nil,
            [
              { building_num: "121", street: "1st Street" },
            ],
          ],
          [
            :us,
            "121",
            "4th Street",
            [
              { building_num: "121", street: "4th Street" },
            ],
          ],
          [
            :us,
            "121 Louis 14th",
            nil,
            [
              { building_num: "121", street: "Louis 14th" },
            ],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "building numbers with directionals but no units" do
        [
          [:us, "8602 NE Zac Lentz Parkway", nil, [{ building_num: "8602", street: "NE Zac Lentz Parkway" }]],
          [
            :us,
            nil,
            "4107 NW 78th St",
            [
              { building_num: "4107", street: "NW 78th St" },
            ],
          ],
          [
            :us,
            "4107",
            "NW 78th St",
            [
              { building_num: "4107", street: "NW 78th St" },
            ],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "building numbers with units but no directionals" do
        [
          [
            # Note that in some places, notably Queens NY, the building number can be hyphenated
            :ca,
            "4-123 Main Street",
            nil,
            [
              { building_num: "123", street: "Main Street", unit_num: "4" },
              { building_num: "4-123", street: "Main Street" },
            ],
          ],
          [
            # Note that in some places, notably Queens NY, the building number can be hyphenated
            :us,
            "4-123",
            "Main Street",
            [
              { building_num: "123", street: "Main Street", unit_num: "4" },
              { building_num: "4-123", street: "Main Street" },
            ],
          ],
          [:us, "125 Bella Bella 106", nil, []],
          [
            :us,
            "2850 Shore Parkway - 1k",
            nil,
            [
              { building_num: "2850", street: "Shore Parkway", unit_num: "1k" },
              { building_num: "2850", street: "Shore Parkway - 1k" },
            ],
          ],
          [
            :us,
            "7309 Swans Run Road, Apt B",
            nil,
            [{ building_num: "7309", street: "Swans Run Road", unit_type: "Apt", unit_num: "B" }],
          ],
          [
            :us,
            "7309 Swans Run Road",
            "Apt B",
            [
              { building_num: "7309", street: "Swans Run Road" },
              { building_num: "7309", street: "Swans Run Road", unit_type: "Apt", unit_num: "B" },
            ],
          ],
          [
            :us,
            "3952 D Clairemont Meas Blvd (Mail only)",
            "Suite 281",
            [
              { building_num: "3952", street: "D Clairemont Meas Blvd (Mail only)" },
              {
                building_num: "3952",
                street: "D Clairemont Meas Blvd (Mail only)",
                unit_type: "Suite",
                unit_num: "281",
              },
            ],
          ],
          [
            :us,
            "12948 S US 31 lot 59",
            "",
            [
              { building_num: "12948", street: "S US 31", unit_type: "lot", unit_num: "59" },
            ],
          ],
          [
            :us,
            "3015 Palisades Dr Unit 102",
            "",
            [
              { building_num: "3015", street: "Palisades Dr", unit_type: "Unit", unit_num: "102" },
            ],
          ],
          [
            :us,
            "20 Shea Way, Ste. 205, KX050668",
            "",
            [
              { building_num: "20", street: "Shea Way, Ste. 205, KX050668" },
              { building_num: "20", street: "Shea Way", unit_type: "Ste.", unit_num: "205" },
            ],
          ],
          [
            :us,
            "930 NW 84TH AVE SMART GADGET  SGR1632",
            "",
            [
              { building_num: "930", street: "NW 84TH AVE" },
            ],
          ],
          [
            :us,
            "915 Josh Drive in care of Allen Early",
            "",
            [
              { building_num: "915", street: "Josh Drive" },
            ],
          ],
          [
            :us,
            "5859 Tom Hebert Rd Trlr 57",
            nil,
            [{ building_num: "5859", street: "Tom Hebert Rd", unit_type: "Trlr", unit_num: "57" }],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "building numbers with both unit numbers and directionals" do
        [
          [
            :us,
            "123 Main St E Apt 4",
            nil,
            [{ building_num: "123", street: "Main St E", unit_type: "Apt", unit_num: "4" }],
          ],
          [
            :us,
            "4465 W Hacienda",
            "#106",
            [
              { building_num: "4465", street: "W Hacienda" },
              { building_num: "4465", street: "W Hacienda", unit_num: "106" },
            ],
          ],
          [:us, nil, "463 E 147 St. #2F", [{ building_num: "463", street: "E 147 St.", unit_num: "2F" }]],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "street name is also a unit designator" do
        [
          [
            :us,
            "11 W Front St",
            nil,
            [
              { building_num: "11", street: "W Front St" },
              { building_num: "11", street: "W", unit_type: "Front", unit_num: "St" },
            ],
          ],
          [
            :us,
            "4 Unit St",
            "#106",
            [
              { building_num: "4", street: "Unit St" },
              { building_num: "4", street: "Unit St", unit_num: "106" },
            ],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "Queens' hyphenated building numbers" do
        [
          [
            :us,
            "97-45 Queens Boulevard, Apt 703",
            [{ building_num: "97-45", street: "Queens Boulevard", unit_type: "Apt", unit_num: "703" }],
          ],
        ].each do |country_code, input, expected|
          check_parsing(country_code, input, nil, expected)
        end
      end

      test "Building numbers that start with a letter" do
        [
          [:us, "A1 Colonial Drive", nil, [{ building_num: "A1", street: "Colonial Drive" }]],
          [:us, "A30", "Colonial Drive", [{ building_num: "A30", street: "Colonial Drive" }]],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "Building numbers that end in a letter" do
        [
          [
            :ca,
            "2A Woodbine Place",
            nil,
            [
              { building_num: "2A", street: "Woodbine Place" },
              { building_num: "2", street: "A Woodbine Place" },
            ],
          ],
          [
            :ca,
            "2 A Woodbine Place",
            nil,
            [
              { building_num: "2", street: "A Woodbine Place" },
            ],
          ],
          [
            :ca,
            "2A Woodbine Place",
            "Apt C",
            [
              {
                building_num: "2A",
                street: "Woodbine Place",
                unit_type: "Apt",
                unit_num: "C",
              },
              { building_num: "2A", street: "Woodbine Place" },
              {
                building_num: "2",
                street: "A Woodbine Place",
                unit_type: "Apt",
                unit_num: "C",
              },
              { building_num: "2", street: "A Woodbine Place" },
            ],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "Building numbers that start and end in a letter" do
        [
          [
            :us,
            "C1A Calle Tirado Garcia",
            [{ building_num: "C1A", street: "Calle Tirado Garcia" }],
          ],
        ].each do |country_code, input, expected|
          check_parsing(country_code, input, nil, expected)
        end
      end

      test "Fractional building numbers" do
        [
          [:ca, "12/A Fake Road", nil, [{ building_num: "12/A", street: "Fake Road" }]],

          # This is a real address:  26 1/2 South Main Street, Belchertown MA 01007
          [
            :us,
            "26 1/2",
            "South Main Street",
            [
              { building_num: "26", street: "1/2" },
              { building_num: "26 1/2", street: "South Main Street" },
              { building_name: "26", building_num: "1/2", street: "South Main Street" },
            ],
          ],

          # Also a real address (believe it or not):  1/2 Nelson Street, Clinton MA 01510
          [:us, nil, "1/2 Nelson Street", [{ building_num: "1/2", street: "Nelson Street" }]],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "returned results have no duplicates" do
        [
          [:ca, "1219 William Street"],
        ].each do |country_code, input|
          address = build_address(country_code: country_code, address1: input, address2: nil)
          results = AddressParserNorthAmerica.new(address: address).parse
          assert_equal results.count, results.to_set.count, "INPUT was #{input.inspect}"
        end
      end

      test "numbered routes" do
        [
          [:ca, "3990 Highway 7A", nil, [{ building_num: "3990", street: "Highway 7A" }]],
          [:us, "350", "State Hwy 15", [{ building_num: "350", street: "State Hwy 15" }]],
          [:us, nil, "2520 County Rd H2", [{ building_num: "2520", street: "County Rd H2" }]],
          [:us, "11068 County Rd b", nil, [{ building_num: "11068", street: "County Rd b" }]],
          [:us, "491 County Rd AAJ", nil, [{ building_num: "491", street: "County Rd AAJ" }]],
          [:us, "615 County Hwy 2", nil, [{ building_num: "615", street: "County Hwy 2" }]],
          [:us, "615 County Highway 2", nil, [{ building_num: "615", street: "County Highway 2" }]],
          [:us, "6298 Carr. 164", nil, [{ building_num: "6298", street: "Carr. 164" }]],
          [:us, "5832 State Route 5 And 20", nil, [{ building_num: "5832", street: "State Route 5 And 20" }]],
          [:us, "872 North Old US Highway 23", nil, [{ building_num: "872", street: "North Old US Highway 23" }]],
          [:us, "2550 AN COUNTY ROAD 485", nil, [{ building_num: "2550", street: "AN COUNTY ROAD 485" }]],
          [:us, "18056 CSAH 14", nil, [{ building_num: "18056", street: "CSAH 14" }]],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "numbered routes with directionals" do
        [
          [
            {
              address1: "29767 South County Highway 395 #6302",
              city: "Santa Rosa Beach",
              province_code: "FL",
              zip: "32459",
              country_code: "US",
            },
            { building_num: "29767", street: "South County Highway 395", unit_num: "6302" },
          ],
          [
            {
              address1: "1755 N Co Hwy 285",
              city: "Defuniak Springs",
              province_code: "FL",
              zip: "32433",
              country_code: "US",
            },
            { building_num: "1755", street: "N Co Hwy 285" },
          ],
          [
            {
              address1: "853 County Rd 1 N",
              city: "Jones",
              province_code: "AL",
              zip: "36749",
              country_code: "US",
            },
            { building_num: "853", street: "County Rd 1 N" },
          ],
          [
            {
              address1: "4900 E Co Rd 2 S",
              city: "Monte Vista",
              province_code: "CO",
              zip: "81144",
              country_code: "US",
            },
            { building_num: "4900", street: "E Co Rd 2 S" },
          ],
        ].each do |address_specification, expected|
          check_address_parsing(address_specification, expected)
        end
      end

      test "numbered streets with directionals" do
        [
          [:us, "5808 8055 South", "L304", [{ building_num: "5808", street: "8055 South" }]],
          [:us, "5784 W 7935 S", nil, [{ building_num: "5784", street: "W 7935 S" }]],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "building name" do
        [
          [
            :us,
            "Adler Planetarium",
            "1300 South Lake Shore Drive",
            [
              { building_name: "Adler Planetarium", building_num: "1300", street: "South Lake Shore Drive" },
              { building_num: "1300", street: "South Lake Shore Drive" },
            ],
          ],
          [
            :us,
            "Adler Planetarium 1300 South Lake Shore Drive",
            nil,
            [{ building_name: "Adler Planetarium", building_num: "1300", street: "South Lake Shore Drive" }],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "unit number before building number" do
        [
          [
            :us,
            "Suite 4 123 Main Street",
            nil,
            [
              { unit_type: "Suite", unit_num: "4", building_num: "123", street: "Main Street" },
              { building_name: "Suite 4", building_num: "123", street: "Main Street" },
            ],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "unrecocognized additional information" do
        [
          [
            :us,
            "3400 Austin Lane",
            "buzzer code 1234",
            [{ building_num: "3400", street: "Austin Lane" }],
          ],
          [
            :us,
            "3400 Austin Lane buzzer code 1234",
            nil,
            [
              { building_num: "3400", street: "Austin Lane" },
            ],
          ],
          [
            :us,
            "3400 Austin Lane",
            "leave on porch",
            [
              { building_num: "3400", street: "Austin Lane" },
            ],
          ],
          [
            :us,
            "c/o John Smith",
            "3400 Austin Lane",
            [{ building_num: "3400", street: "Austin Lane" }],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "missing space between building number and street name" do
        [
          [
            :us,
            "200LaSalle",
            nil,
            [
              { building_num: "200", street: "LaSalle" },
            ],
          ],
          [
            :us,
            "4192Longbranch Rd",
            nil,
            [
              { building_num: "4192", street: "Longbranch Rd" },
            ],
          ],
          [
            :us,
            "1E MAIN ST",
            nil,
            [
              { building_num: "1", street: "E MAIN ST" },
              { building_num: "1E", street: "MAIN ST" },
            ],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "address 2 information duplicated in address1" do
        [
          [
            :us,
            "286 Quaker Church Road, Christiana, Christiana",
            "Christiana",
            { city: "Lancaster", zip: "17509", province_code: "PA" },
            [
              { building_num: "286", street: "Quaker Church Road, Christiana, Christiana" },
            ],
          ],
        ].each do |country_code, address1, address2, components, expected|
          check_parsing(country_code, address1, address2, expected, components)
        end
      end

      test "city, province, country information included in address1" do
        [
          [
            :us,
            "2753 Greenway Drive, Frisco, TX, US",
            nil,
            { city: "Frisco", province_code: "TX" },
            [{ building_num: "2753", street: "Greenway Drive" }],
          ],
          [
            # Street name is same as province name
            :us,
            "1023 New York Ave, Brooklyn, NY 11203",
            nil,
            { city: "Brooklyn", province_code: "NY" },
            [],
          ],
        ].each do |country_code, address1, address2, components, expected|
          check_parsing(country_code, address1, address2, expected, components)
        end
      end

      test "zip included in address1" do
        [
          [
            :us,
            "3562 Huddlestone Ln, Buford, GA 30519",
            nil,
            { city: "Buford", province_code: "GA", zip: "30519" },
            [{ building_num: "3562", street: "Huddlestone Ln" }],
          ],
          [
            :us,
            "8124 N 33rd Drive Unit 1 Phoenix Arizona 85051",
            nil,
            { city: "Phoenix", province_code: "AZ", zip: "85051" },
            [{ building_num: "8124", street: "N 33rd Drive", unit_type: "Unit", unit_num: "1" }],
          ],
        ].each do |country_code, address1, address2, components, expected|
          check_parsing(country_code, address1, address2, expected, components)
        end
      end

      test "PO box inputs in various formats" do
        [
          [
            :us,
            "228 West 3rd Street PO Box 1544",
            "",
            [{ building_num: "228", street: "West 3rd Street", po_box: "1544" }],
          ],
          [
            :us,
            "123 Main St",
            "PO Box 321",
            [
              { building_num: "123", street: "Main St", po_box: "321" },
            ],
          ],
          [
            :us,
            "P.O. Box 999",
            "456 High St",
            [
              { building_num: "456", street: "High St", po_box: "999" },
            ],
          ],
          [
            :us,
            "Post Office Box 145",
            "789 Elm Ave",
            [
              { building_num: "789", street: "Elm Ave", po_box: "145" },
            ],
          ],
          [
            :us,
            "2382 West 7200 North P.O. Box 161",
            nil,
            [
              { building_num: "2382", street: "West 7200 North", po_box: "161" },
              { building_name: "2382 West", building_num: "7200", street: "North", po_box: "161" },
            ],
          ],
          [
            :us,
            "2225 coyote loop, postal box 1836",
            nil,
            [{ building_num: "2225", street: "coyote loop", po_box: "1836" }],
          ],
          [:us, "Po box 525 canjilon nm", nil, [{ po_box: "525" }]],
          [
            :us,
            "137 NW 17th Ave/po box 607",
            nil,
            [{ building_num: "137", street: "NW 17th Ave", po_box: "607" }],
          ],
          [
            :us,
            "57186 M/V Australia Lane, Box 150",
            nil,
            [{ building_num: "57186", street: "M/V Australia Lane", po_box: "150" }],
          ],
          [
            :us,
            "211 West 2nd Avenue P.obox 241",
            nil,
            [{ building_num: "211", street: "West 2nd Avenue", po_box: "241" }],
          ],
          [
            :us,
            "JOHN SMITH
              PO BOX 123
              NEW YORK NY 10001",
            nil,
            [{ po_box: "123" }],
          ],
          [
            :us,
            "PO Box 1544",
            nil,
            [{ po_box: "1544" }],
          ],
          [
            :us,
            "Pobox 821",
            nil,
            [{ po_box: "821" }],
          ],
          [
            :us,
            "POBox 1238",
            nil,
            [{ po_box: "1238" }],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "street names that resemble a PO Box regex format, but do not actually contain a PO Box" do
        [
          [
            :us,
            "1480 Salt Box Road",
            "Randolph VT 05061",
            [
              { building_num: "1480", street: "Salt Box Road" },
            ],
          ],
          [
            :us,
            "321 Post Oak Lane",
            "Houston TX 77024",
            [
              { building_num: "321", street: "Post Oak Lane" },
            ],
          ],
          [
            :us,
            "470 Office Park Drive",
            "Birmingham AL 35223",
            [
              { building_num: "470", street: "Office Park Drive" },
            ],
          ],
          [
            :us,
            "900 Boxwood Circle",
            "Roswell GA 30075",
            [
              { building_num: "900", street: "Boxwood Circle" },
            ],
          ],
        ].each do |country_code, address1, address2, expected|
          check_parsing(country_code, address1, address2, expected)
        end
      end

      test "does not combine address lines to parse a street name" do
        address = build_address(address1: "123 Main", address2: "Street", country_code: "US")
        expected = [{ building_num: "123", street: "Main" }]
        assert_equal expected, AddressParserNorthAmerica.new(address: address).parse
      end

      private

      sig { params(address_specification: T::Hash[Symbol, String], expected: T::Hash[Symbol, String]).void }
      def check_address_parsing(address_specification, expected)
        address = build_address(**address_specification)

        actual = AddressParserNorthAmerica.new(address: address).parse
        assert(
          [expected].to_set.subset?(actual.to_set),
          "For input #{address_specification.inspect},\n"\
            "expected parsings to include #{expected.inspect},\n"\
            "but got #{actual.inspect}.",
        )
      end

      def check_parsing(country_code, address1, address2, expected, components = nil)
        components ||= {}
        components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
        address = build_address(**components)

        actual = AddressParserNorthAmerica.new(address: address).parse

        assert(
          expected.to_set.subset?(actual.to_set),
          "For input ( address1: #{address1.inspect}, address2: #{address2.inspect} )\n\n " \
            "#{expected.inspect} \n\n" \
            "Must be included in: \n\n" \
            "#{actual.inspect}",
        )
      end
    end
  end
end
