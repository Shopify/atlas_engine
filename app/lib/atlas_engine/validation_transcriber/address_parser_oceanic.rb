# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class AddressParserOceanic < AddressParserBase
      private

      sig { returns(T::Array[Regexp]) }
      def country_regex_formats
        @country_regex_formats ||= [
          %r{^((?<unit_num>[[:alpha:]0-9]+)/)?(?<building_num>[0-9][[:alpha:]0-9]*)\s+(?<street>.+)$},
        ]
      end
    end
  end
end
