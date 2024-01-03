# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Pl
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            %r{^(?<street>.+)\s+(?<building_num>[0-9][[:alpha:]0-9]*)(\s*/\s*(?<unit_num>[[:alpha:]0-9]+))?$},
          ]
        end
      end
    end
  end
end
