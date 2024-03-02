# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class Cache
          extend T::Sig

          sig { returns(T.nilable(Suggestion)) }
          attr_accessor :suggestion

          sig { params(address: Address).void }
          def initialize(address)
            @address = address
            @empty_region = Worldwide::Region.new(iso_code: "ZZ")
            @suggestion = nil
          end

          sig { returns(Worldwide::Region) }
          def country
            if @address.country_code.present?
              @country ||= Worldwide.region(code: @address.country_code)
            else
              @empty_region
            end
          end

          sig { returns(Worldwide::Region) }
          def province
            if @address.province_code.present?
              @province ||= country.zone(code: @address.province_code)
            else
              @empty_region
            end
          end

          sig { returns(T.nilable(AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison)) }
          def address_comparison
            @address_comparison ||= AddressValidation::Es::CandidateSelector.new(
              datastore: AtlasEngine::AddressValidation::Es::Datastore.new(address: @address),
              address: @address,
            ).best_candidate&.address_comparison # TODO: get rid of the tuple, it's not needed
          end
        end
      end
    end
  end
end
