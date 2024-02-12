# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Nz
    module ValidationTranscriber
      class AddressParser < AtlasEngine::ValidationTranscriber::AddressParserBase
        extend T::Sig

        sig { override.returns(T::Array[AddressComponents]) }
        def parse
          address_components = super

          # TEMPORARY: hacky extraction of suburb for POC
          address_components.map do |parsing|
            parsing[:suburb] = T.must(@address.address2) if @address.address2.present?
          end

          address_components
        end

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
end
