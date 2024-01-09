# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class AddressParsings
      extend T::Sig
      include LogHelper

      ParsedComponents = T.type_alias { T::Hash[Symbol, String] }

      sig { returns(T::Array[ParsedComponents]) }
      attr_reader :parsings

      sig { params(address_input: AddressValidation::AbstractAddress, locale: T.nilable(String)).void }
      def initialize(address_input:, locale: nil)
        @parsings = T.let(
          begin
            if address_input.country_code.blank?
              []
            else
              parsing_result = AddressParserFactory.create(address: address_input, locale: locale).parse
              log_unparsable_address(address_input) if parsing_result.empty?
              parsing_result
            end
          end,
          T::Array[ParsedComponents],
        )
      end

      sig { returns(T::Boolean) }
      def describes_po_box?
        parsings.any? { |parsing| parsing[:po_box] }
      end

      sig { returns(T::Array[String]) }
      def potential_streets
        potential_parsings = parsings.pluck(:street).compact
        potential_parsings << "po box" if describes_po_box?
        potential_parsings.uniq
      end

      sig { returns(T::Array[String]) }
      def potential_building_numbers
        parsings.pluck(:building_num).compact.uniq
      end

      sig { params(address_input: AddressValidation::AbstractAddress).void }
      def log_unparsable_address(address_input)
        log_info("[AddressValidation] Unable to parse address lines", address_input.to_h.except(:phone))
      end
    end
  end
end
