# typed: true
# frozen_string_literal: true

module AtlasEngine
  module At
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        private

        STREET = "(?<street>.+?)"
        NUMBERED_STREET = "(?<street>.+\s+[0-9]+)"
        BUILDING_NUM = "(?<building_num>[0-9]+[[:alpha:]]*)"
        UNIT_NUM = "(?<unit_num>.+)"

        sig { returns(T::Array[Regexp]) }
        def country_regex_formats
          @country_regex_formats ||= [
            %r{^#{STREET},?\s+#{BUILDING_NUM}([\s,-/]+#{UNIT_NUM})?$},
            %r{^#{NUMBERED_STREET},?\s+#{BUILDING_NUM}([\s,-/]+#{UNIT_NUM})?$},
          ]
        end

        sig { override.params(address_line: String).returns(T::Array[T.nilable(String)]) }
        def extract_po_box(address_line)
          [address_line, nil]
        end

        # Return true if something's obviously wrong with this regex match
        sig do
          override.params(
            captures: T::Hash[Symbol, T.nilable(String)],
            address: AddressValidation::TAddress,
          ).returns(T::Boolean)
        end
        def ridiculous?(captures, address)
          street = captures[:street]&.downcase

          if street.present?
            true unless address.address1&.upcase&.include?(street.upcase) ||
              address.address2&.upcase&.include?(street.upcase)
          end

          false
        end

        sig { override.params(token: T.nilable(String)).returns(T::Boolean) }
        def po_box?(token)
          false
        end

        sig { override.params(token: T.nilable(String)).returns(T::Boolean) }
        def street_suffix?(token)
          false
        end
      end
    end
  end
end
