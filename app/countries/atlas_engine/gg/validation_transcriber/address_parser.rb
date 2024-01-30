# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Gg
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        UNIT_NUM = /(?<unit_num>.+)/
        CITY = /(?<city>St Saviours|St Martins|St Martin|St Peters)/

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /^#{STREET_NO_COMMAS}\s+#{BUILDING_NUM}(,\s*#{UNIT_NUM})?$/,
            /^#{STREET_NO_COMMAS}\s+#{BUILDING_NUM}\s+#{CITY}$/,
          ]
        end
      end
    end
  end
end
