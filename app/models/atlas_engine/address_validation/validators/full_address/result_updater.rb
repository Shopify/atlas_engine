# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ResultUpdater
          extend T::Sig
          extend T::Helpers
          abstract!

          sig { params(session: Session, result: Result).void }
          def initialize(session:, result:)
            @session = session
            @result = result
          end

          private

          attr_reader :session, :result

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
