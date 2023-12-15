# typed: false
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class EnglishStreetParser
      include AddressParsingHelper

      def initialize
        super
      end

      def parse(street:)
        return {} if street.blank?

        # Expected format: [pre_directional, name, suffix, post_directional]
        # Note that pre_directional and post_directional may be absent, one word ("East"), or two words ("North East")

        pre_directional = nil
        suffix = nil
        post_directional = nil

        tokens = street.split(" ")

        if directional?(tokens[0])
          if directional?(tokens[1])
            pre_directional = tokens[0..1].join(" ")
            tokens = tokens[2..-1]
          else
            pre_directional = tokens[0]
            tokens = tokens[1..-1]
          end
        end

        if directional?(tokens[-1])
          if directional?(tokens[-2])
            post_directional = tokens[-2..-1].join(" ")
            tokens = tokens[0..-3]
          else
            post_directional = tokens[-1]
            tokens = tokens[0..-2]
          end
        end

        if street_suffix?(tokens[-1])
          suffix = tokens[-1]
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
