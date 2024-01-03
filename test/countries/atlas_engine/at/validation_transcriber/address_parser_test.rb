# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module At
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include ValidationTranscriber

        test "CountryProfile for AT loads the correct address parser" do
          assert_equal(AddressParser, CountryProfile.for("AT").validation.address_parser)
        end

        test "One line Austrian addresses" do
          [
            # standard format, single word street name, with building number
            [:at, "Kakteenstraße 4", [{ street: "Kakteenstraße", building_num: "4" }]],
            # street has accented character
            [:at, "Völkendorferstr 92", [{ street: "Völkendorferstr", building_num: "92" }]],
            # building and unit number separated by slash
            [:at, "Spankerenseweg 34/H", [{ street: "Spankerenseweg", building_num: "34", unit_num: "H" }]],
            # street with dash and dot in name
            [
              :at,
              "Leopold Gattringer-Str. 81/1",
              [{ street: "Leopold Gattringer-Str.", building_num: "81", unit_num: "1" }],
            ],
            # two subpremise numbers after building number
            [:at, "Archengasse 9/3/33", [{ street: "Archengasse", building_num: "9", unit_num: "3/33" }]],
            # three subpremise numbers after building number
            [:at, "Archengasse 9/3/33/A", [{ street: "Archengasse", building_num: "9", unit_num: "3/33/A" }]],
            # subpremise has many words and numbers
            [
              :at,
              "Dieselgasse 5A/48 Stock 3 Tür 48",
              [{ street: "Dieselgasse", building_num: "5A", unit_num: "48 Stock 3 Tür 48" }],
            ],
            # dash separates building and unit number, with slashes in unit number
            [
              :at,
              "Pilzgasse 23-29/6/30",
              [{ street: "Pilzgasse", building_num: "23", unit_num: "29/6/30" }],
            ],
            # street, building and unit separated by spaces
            [
              :at,
              "Sonja Hajek Weg 7 Top 5",
              [{ street: "Sonja Hajek Weg", building_num: "7", unit_num: "Top 5" }],
            ],
            # comma separates street and building number
            [
              :at,
              "Wienerstrasse, 11/5/1",
              [{ street: "Wienerstrasse", building_num: "11", unit_num: "5/1" }],
            ],
          ].each do |country_code, address1, expected|
            check_parsing(country_code, address1, nil, expected)
          end
        end

        test "Two line Austrian addresses" do
          [
            # street and building number on address1, unit on address2
            [
              :at,
              "Linke Wienzeile  280",
              "Top 11",
              [{ street: "Linke Wienzeile", building_num: "280", unit_num: "Top 11" }],
            ],
            # street on address1, building number and unit on address2
            [
              :at,
              "Lindenweg",
              "3/4",
              [
                { street: "Lindenweg", building_num: "3", unit_num: "4" },
              ],
            ],
            # unit split across lines
            [
              :at,
              "Untere Viaduktgasse 51/3",
              "Tür 3",
              [
                { street: "Untere Viaduktgasse", building_num: "51", unit_num: "3 Tür 3" },
              ],
            ],
          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        test "Parsings with an without street number when ambiguous" do
          [
            [
              :at,
              "Sonnwiesen Straße 1 2",
              nil,
              [
                { street: "Sonnwiesen Straße", building_num: "1", unit_num: "2" },
                { street: "Sonnwiesen Straße 1", building_num: "2" },
              ],
            ],
            [
              :at,
              "Sonnwiesen Straße 1",
              "2",
              [
                { street: "Sonnwiesen Straße", building_num: "1", unit_num: "2" },
                { street: "Sonnwiesen Straße 1", building_num: "2" },
              ],
            ],
            [
              :at,
              "Sonnwiesen Straße 1",
              "2 Top 11",
              [
                { street: "Sonnwiesen Straße", building_num: "1", unit_num: "2 Top 11" },
                { street: "Sonnwiesen Straße 1", building_num: "2", unit_num: "Top 11" },
              ],
            ],
          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        private

        def check_parsing(country_code, address1, address2, expected, components = nil)
          components ||= {}
          components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
          address = AddressValidation::Address.new(**components)

          actual = AddressParser.new(address: address).parse

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
end
