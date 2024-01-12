# typed: false
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class FrenchStreetParser
      include AddressParsingHelper

      def initialize
        super
      end

      def parse(street:)
        return {} if street.blank?

        # Expected format: [suffix, pre_directional, name, post_directional]
        # Note that the directionals may be absent.
        # Suffix is actually a prefix in French, but we keep the existing terminology for cross-language consistency.

        suffix = nil
        pre_directional = nil
        post_directional = nil

        tokens = street.split(" ")

        if street_suffix?(tokens[0])
          suffix = tokens[0]
          tokens = tokens[1..-1]
        end

        if directional?(tokens[0])
          pre_directional = tokens[0]
          tokens = tokens[1..-1]
        end

        if directional?(tokens[-1])
          post_directional = tokens[-1]
          tokens = tokens[0..-2]
        end

        {
          pre_directional: pre_directional,
          name: tokens.join(" "),
          suffix: suffix,
          post_directional: post_directional,
        }.compact_blank.to_h
      end
    end
  end
end
