# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module Corrections
      class Corrector
        extend T::Sig
        attr_reader :correctors

        sig { params(country_code: String, source: String).void }
        def initialize(country_code:, source:)
          @country_code = country_code.upcase
          @correctors ||= correctors_for_country(@country_code, source)
        end

        sig { params(address: Hash).void }
        def apply(address)
          correctors.each do |corrector|
            corrector.apply(address)
          end
        end

        private

        sig { params(country_code: String, source: String).returns(T::Array[Class]) }
        def correctors_for_country(country_code, source)
          CountryProfile.for(country_code).ingestion.correctors(source: source)
        end
      end
    end
  end
end
