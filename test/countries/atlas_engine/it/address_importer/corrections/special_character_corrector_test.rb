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
                ["Via CefalÃ¹", "Via Cefalù"],
                ["Via CalabrÃ²", "Via Calabrò"],
                ["Via LÃ³", "Via Ló"],
                ["Largo SanitÃ¡", "Largo Sanitá"],
                ["Via VidÃ¢L", "Via VidâL"],
                ["Strada ParÃ¼s", "Strada Parüs"],
                ["Via Antonio MuÃ±Oz", "Via Antonio MuñOz"],
                ["Strada Col PinÃ«I", "Strada Col PinëI"],
                ["Via di SoprÃ¨", "Via di Soprè"],
                ["Via Privata Paolo CÃ©Zanne", "Via Privata Paolo CéZanne"],
                ["Via CjafurchÃ®r", "Via Cjafurchîr"],
                ["Via RÃ´Sas di Cella", "Via RôSas di Cella"],
                ["Via VidisÃªt", "Via Vidisêt"],
                ["Via CÃ»R Vilan", "Via CûR Vilan"],
                ["Rione GÃ¶Ller", "Rione GöLler"],
                ["Discesa CalÃ¬", "Discesa Calì"],
                ["Via LÃ¤Rch", "Via LäRch"],
                ["Via EvanÃ§On", "Via EvançOn"],
                ["Piazza Sire RaÃºl", "Piazza Sire Raúl"],
                ["Via della LibertÃ", "Via della Libertà"],
                ["Casa Sparse LocalitÃ RÃ¨", "Casa Sparse Località Rè"],
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
