# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class LogEmitter
      extend T::Sig
      include LogHelper

      sig { returns(AbstractAddress) }
      attr_reader :address

      sig { returns(AddressValidation::Result) }
      attr_reader :result

      sig { returns(T::Array[Symbol]) }
      attr_reader :fields

      sig do
        params(
          address: AbstractAddress,
          result: AddressValidation::Result,
        ).void
      end
      def initialize(address:, result:)
        @address = address
        @result = result
        @fields = [:country, :province, :zip, :city, :street, :phone]
      end

      sig { void }
      def run
        formatted_address = I18n.with_locale(:en) do
          Worldwide.address(**address.to_h).single_line
        end
        data = {
          country_code: address.country_code,
          formatted_address: formatted_address,
          concerns: concern_codes,
          suggestions: result.suggestions.map(&:attributes),
          candidate: result.candidate,
          validation_id: result.id,
        }

        if concern_codes.any?
          log_info("[AddressValidation] Concern(s) found when validating address", data)
        else
          log_info("[AddressValidation] Address validated, no concerns returned", data)
        end
      end

      sig { returns(T::Array[Symbol]) }
      def concern_codes
        fields.flat_map do |field|
          if field.equal?(:street)
            result.concerns.select do |c|
              c.attributes[:code] =~ /^(missing_building_number|address1|address2|street).*/
            end
          else
            result.concerns.select { |c| c.attributes[:code] =~ /^#{field}.*/ }
          end
        end.map(&:code)
      end
    end
  end
end
