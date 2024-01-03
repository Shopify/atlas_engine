# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Lt
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        STREET = "(?<street>.+?)"
        BUILDING_NUM = "(?<building_num>[0-9]+[[:alpha:]]*)"
        UNIT_NUM = "(?<unit_num>[0-9]+[[:alpha:]]*)"

        sig { override.returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /^#{STREET}\s#{BUILDING_NUM}/i,
            /^#{STREET}\s#{BUILDING_NUM}-#{UNIT_NUM}/i,
          ]
        end
      end
    end
  end
end
