# typed: true
# frozen_string_literal: true

module AtlasEngine
  module De
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /^#{STREET_NO_COMMAS}\s+#{BUILDING_NUM}$/,
          ]
        end
      end
    end
  end
end
