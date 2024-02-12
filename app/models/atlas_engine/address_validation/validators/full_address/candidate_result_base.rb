# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class CandidateResultBase
          extend T::Helpers
          extend T::Sig

          abstract!

          sig { params(country: Worldwide::Region, session: Session, result: Result).void }
          def initialize(country:, session:, result:)
            @country = country
            @session = session
            @result = result
          end

          sig { void }
          def update_result; end

          private

          attr_reader :session, :result, :country

          delegate :address, to: :session

          sig { void }
          def update_result_scope
            concern_fields = result.concerns.flat_map(&:field_names).uniq
            scopes_to_remove = concern_fields.flat_map { |field| contained_scopes_for(field) }
            result.validation_scope.reject! { |scope| scope.in?(scopes_to_remove) }
          end

          sig { params(scope: Symbol).returns(T.nilable(T::Array[Symbol])) }
          def contained_scopes_for(scope)
            return [] unless (scope_index = Result::SORTED_VALIDATION_SCOPES.index(scope))

            Result::SORTED_VALIDATION_SCOPES.slice(scope_index..)
          end
        end
      end
    end
  end
end
