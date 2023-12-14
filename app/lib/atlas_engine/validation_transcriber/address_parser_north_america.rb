# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class AddressParserNorthAmerica < AddressParserBase
      private

      sig { returns(T::Array[Regexp]) }
      def country_regex_formats
        @country_regex_formats ||= [
          "#{BUILDING_NUM}(?<num_street_space>\s+)#{STREET}",
          "#{NUMERIC_ONLY_BUILDING_NUM}#{NON_NUMERIC_STREET}",
        ].map do |building_and_street_expr|
          north_american_variants(building_and_street_expr)
        end.flatten.uniq
      end

      # {building_num} {street}
      # {unit_num}-{building_num} {street}
      # {building_num} {street} {unit_type} {unit_num}
      # {building_num} {street} #{unit_num}
      # {building_num} {street} {unit_num}
      # {building_num} {street} - {unit_num}
      sig { params(building_and_street_expr: String).returns(T::Array[Regexp]) }
      def north_american_variants(building_and_street_expr)
        [
          /^#{building_and_street_expr}$/,
          /^(#{UNIT_NUM_NO_HYPHEN}-)?#{building_and_street_expr}$/,
          /^#{building_and_street_expr}\s+#{UNIT_TYPE}\s+#{UNIT_NUM}/,
          /^#{building_and_street_expr}\s+\#\s*#{UNIT_NUM}/,
          /^#{building_and_street_expr}\s+-\s+#{UNIT_NUM}/,
          /^#{BUILDING_NAME}\s#{building_and_street_expr}$/,
          /^#{UNIT_TYPE}\s+#{UNIT_NUM_NO_HYPHEN}\s+#{building_and_street_expr}$/,
        ]
      end
    end
  end
end
