# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Nl
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        test "One line Dutch addresses" do
          [
            # standard format with building number
            [:nl, "De Hees 17", [{ street: "De Hees", building_num: "17" }]],
            # street has accented character
            [:nl, "Burgemeester Françoisplein 17", [{ street: "Burgemeester Françoisplein", building_num: "17" }]],
            # building number always starts with a digit
            [:nl, "Langbroekerdijk A 39", [{ street: "Langbroekerdijk A", building_num: "39" }]],
            # building and unit number separated by comma
            [:nl, "Spankerenseweg 34, H", [{ street: "Spankerenseweg", building_num: "34", unit_num: "H" }]],
            # alphanumeric building number (the letter is likely a unit number, but we don't care)
            [:nl, "Van Woustraat 165h", [{ street: "Van Woustraat", building_num: "165h" }]],
            # spaces between street, building and unit number
            [
              :nl,
              "Juliana Van Stolberglaan 116 109",
              [
                { street: "Juliana Van Stolberglaan 116", building_num: "109" },
                { street: "Juliana Van Stolberglaan", building_num: "116", unit_num: "109" },
              ],
            ],
            # dash in street name
            [:nl, "Aletta Jacobs-erf 168", [{ street: "Aletta Jacobs-erf", building_num: "168" }]],
            # dash between building number and unit number
            [:nl, "Orteliuskade 27-I", [{ street: "Orteliuskade", building_num: "27", unit_num: "I" }]],
            # numbered street with building number. bad format leads to bad interpretation
            [:nl, "Kogge 08-53", [{ street: "Kogge", building_num: "08", unit_num: "53" }]],
            # street named Singel with building number and unit number
            [:nl, "Singel 213-1", [{ street: "Singel", building_num: "213", unit_num: "1" }]],
            # street having dash in name (some streets contain year ranges)
            [
              :nl,
              "Singel 40-45 219",
              [
                { street: "Singel 40-45", building_num: "219" },
              ],
            ],
          ].each do |country_code, address1, expected|
            check_parsing(country_code, address1, nil, expected)
          end
        end

        test "Two line Dutch addresses" do
          [
            # building number on address2
            [:nl, "Op de Peelberg", "22", [{ street: "Op de Peelberg", building_num: "22" }]],
            # numbered street with building number, unit on address2
            [
              :nl,
              "Juliana Van Stolberglaan 116",
              "109",
              [
                { street: "Juliana Van Stolberglaan 116", building_num: "109" },
                { street: "Juliana Van Stolberglaan", building_num: "116", unit_num: "109" },
              ],
            ],
          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        test "Isolates Dutch post office boxes" do
          [
            [:nl, "Postbus 123", nil, [{ po_box: "123" }]],
            [:nl, "PB 12345", nil, [{ po_box: "12345" }]],
            [:nl, "Antwoordnummer 123", nil, [{ po_box: "123" }]],
            [
              :nl,
              "Hoofdstraat 12, Postbus 1234",
              nil,
              [{ street: "Hoofdstraat", building_num: "12", po_box: "1234" }],
            ],
            [
              :nl,
              "Hoofdstraat 12",
              "Postbus 1234",
              [{ street: "Hoofdstraat", building_num: "12", po_box: "1234" }],
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
