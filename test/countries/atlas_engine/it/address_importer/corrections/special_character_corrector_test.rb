# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module It
    module AddressImporter
      module Corrections
        module OpenAddress
          class SpecialCharacterCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = SpecialCharacterCorrector
            end

            test "apply replaces incorrect characters in the city" do
              cities = [
                ["Cefalã\u0099", "Cefalù"],
                ["Revã\u0092", "Revò"],
                ["Almã\u0088", "Almè"],
                ["Panchiã\u0080", "Panchià"],
                ["Leinã\u008C", "Leinì"],
              ]

              cities.each do |incorrect_city, correct_city|
                input_address = {
                  city: [incorrect_city],
                  street: "street",
                }

                expected = input_address.merge({ city: [correct_city] })

                @klass.apply(input_address)

                assert_equal expected, input_address
              end
            end

            test "apply replaces incorrect characters in the street" do
              # The casing still needs to be fixed in many of these cases
              streets = [
                ["Via Cefalã¹", "Via Cefalù"],
                ["Via Calabrã²", "Via Calabrò"],
                ["Via Lã³", "Via Lò"],
                ["Largo Sanitã¡", "Largo Sanità"],
                ["Via Vidã¢L", "Via VidâL"],
                ["Strada Parã¼s", "Strada Parüs"],
                ["Via Antonio Muã±Oz", "Via Antonio MuñOz"],
                ["Strada Col Pinã«I", "Strada Col PinëI"],
                ["Via di Soprã¨", "Via di Soprè"],
                ["Via Privata Paolo Cã©Zanne", "Via Privata Paolo CeZanne"],
                ["Via Cjafurchã®r", "Via Cjafurchir"],
                ["Via Rã´Sas di Cella", "Via RoSas di Cella"],
                ["Via Vidisãªt", "Via Vidisêt"],
                ["Via Cã»R Vilan", "Via CuR Vilan"],
                ["Rione Gã¶Ller", "Rione GöLler"],
                ["Discesa Calã¬", "Discesa Calì"],
                ["Via Lã¤Rch", "Via LaRch"],
                ["Via Evanã§On", "Via EvancOn"],
                ["Piazza Sire Raãºl", "Piazza Sire Raul"],
                ["Via della Libertã", "Via della Libertà"],
                ["Casa Sparse Localitã Rã¨", "Casa Sparse Località Rè"],
              ]

              streets.each do |incorrect_street, correct_street|
                input_address = {
                  city: ["city"],
                  street: incorrect_street,
                }

                expected = input_address.merge({ street: correct_street })

                @klass.apply(input_address)

                assert_equal expected, input_address
              end
            end

            test "apply does nothing for addresses without incorrect special characters" do
              input_address = {
                city: ["San Severo"],
                street: "Largo Sanità",
              }

              expected = input_address

              @klass.apply(input_address)

              assert_equal expected, input_address
            end
          end
        end
      end
    end
  end
end
