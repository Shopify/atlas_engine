# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Dk
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        UNIT_NUM = /(?<unit_num>.+)/

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /^#{STREET_NO_COMMAS}\s+#{BUILDING_NUM}(,\s*#{UNIT_NUM})?$/,
          ]
        end
      end
    end
  end
end
