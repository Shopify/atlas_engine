# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Nl
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        STREET = "(?<street>.+)"
        NUMBERED_STREET = "(?<street>.+\s+[0-9]+)"
        BUILDING_NUM = "(?<building_num>[0-9]+[:alpha:]*)"
        UNIT_NUM = "(?<unit_num>[[:alnum:]]+)"
        PO_BOX = /\b(?<box_type>pb|postbus|antwoordnummer)\s+(?<number>\d+)\b/i
        # since not all street synonyms are street suffixes, we cannot read them from the synonyms file
        # TODO synonyms in the file should be grouped by type
        STREET_SUFFIXES = %r{
          \A(
            dwarsstraat|dwstr|dwarsweg|dwwg|dijk|dk|gracht|gr|kade|kd|kanaal|kan
            |laan|leane|loane|ln|park|pk|plantsoen|plnts|plein|pln|singel|sngl
            |straat|strjitte|str|straatweg|strwg|weg|wg
          )\z
        }ix

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            /^#{STREET},?\s+#{BUILDING_NUM}$/,
            /^#{NUMBERED_STREET},?\s+#{BUILDING_NUM}$/,
            /^#{STREET},?\s+#{BUILDING_NUM}[\s,-]+#{UNIT_NUM}$/,
            /^#{NUMBERED_STREET},?\s+#{BUILDING_NUM}[\s,-]+#{UNIT_NUM}$/,
          ]
        end

        sig { override.params(address_line: String).returns(T::Array[T.nilable(String)]) }
        def extract_po_box(address_line)
          po_box_match = address_line.match(PO_BOX)

          if po_box_match
            po_box = po_box_match["number"]
            address_line = address_line.gsub(PO_BOX, "").strip.delete_suffix(",")
          else
            po_box = nil
          end

          [address_line, po_box]
        end

        # Return true if something's obviously wrong with this regex match
        sig do
          override.params(
            captures: T::Hash[Symbol, T.nilable(String)],
            address: AddressValidation::TAddress,
          ).returns(T::Boolean)
        end
        def ridiculous?(captures, address)
          building_num = captures[:building_num]&.downcase
          street = captures[:street]&.downcase
          unit_num = captures[:unit_num]&.downcase

          if street.present?
            return true unless address.address1&.upcase&.include?(street.upcase) ||
              address.address2&.upcase&.include?(street.upcase)
          end

          [building_num, unit_num].any? do |token|
            po_box?(token) || street_suffix?(token)
          end
        end

        sig { override.params(token: T.nilable(String)).returns(T::Boolean) }
        def po_box?(token)
          return false if token.blank?

          token.match?(PO_BOX)
        end

        sig { override.params(token: T.nilable(String)).returns(T::Boolean) }
        def street_suffix?(token)
          token.present? && token.match?(STREET_SUFFIXES)
        end
      end
    end
  end
end
