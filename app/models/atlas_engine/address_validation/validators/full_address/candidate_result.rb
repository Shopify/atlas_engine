# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class CandidateResult < CandidateResultBase
          extend T::Sig
          include LogHelper

          delegate :street_comparison, to: :address_comparison

          sig do
            params(
              candidate: AddressValidation::CandidateTuple,
              session: Session,
              result: Result,
            )
              .void
          end
          def initialize(candidate:, session:, result:)
            super(session: session, result: result)
            @candidate = candidate.candidate
            @address_comparison = candidate.address_comparison
          end

          sig { override.void }
          def update_result
            result.candidate = candidate.serialize
            return if unmatched_components_to_validate.empty?

            update_concerns_and_suggestions
            update_result_scope
          end

          sig { returns(T::Boolean) }
          def suggestable?
            ConcernBuilder.should_suggest?(session.address, unmatched_components.keys)
          end

          private

          sig { returns(Candidate) }
          attr_reader :candidate

          sig { returns(AddressComparison) }
          attr_reader :address_comparison

          sig { void }
          def update_concerns_and_suggestions
            if suggestable?
              add_concerns_with_suggestions
            else
              add_concerns_without_suggestions
            end
          end

          sig { void }
          def add_concerns_without_suggestions
            concern = InvalidZipConcernBuilder.for(session.address, [])
            result.concerns << concern if concern

            if ConcernBuilder.too_many_unmatched_components?(session.address, unmatched_components.keys)
              result.concerns << UnknownAddressConcern.new(session.address)
            end
          end

          sig { void }
          def add_concerns_with_suggestions
            unmatched_components_to_validate.keys.each do |unmatched_component|
              field_name = field_name(unmatched_component)
              if field_name.nil?
                log_unknown_field_name
                next
              end

              concern = ConcernBuilder.new(
                unmatched_component: unmatched_component,
                unmatched_field: field_name,
                matched_components: matched_components_to_validate.keys,
                address: session.address,
                suggestion_ids: [suggestion.id].compact,
              ).build
              result.concerns << concern
            end
            result.suggestions << suggestion
          end

          sig { returns(Suggestion) }
          def suggestion
            unmatched_fields = { street: field_name(:street) }.compact

            @suggestion ||= SuggestionBuilder.from_comparisons(
              session.address.to_h,
              unmatched_components_to_validate,
              candidate,
              unmatched_fields,
            )
          end

          sig { returns(T::Hash[Symbol, AtlasEngine::AddressValidation::Token::Sequence::Comparison]) }
          def matched_components
            @matched_components || split_matched_and_unmatched_components.first
          end

          sig { returns(T::Hash[Symbol, AtlasEngine::AddressValidation::Token::Sequence::Comparison]) }
          def unmatched_components
            @unmatched_components || split_matched_and_unmatched_components.second
          end

          sig { returns(T::Hash[Symbol, AtlasEngine::AddressValidation::Token::Sequence::Comparison]) }
          def matched_components_to_validate
            matched_components.select do |k, _v|
              components_to_validate.include?(k)
            end
          end

          sig { returns(T::Hash[Symbol, AtlasEngine::AddressValidation::Token::Sequence::Comparison]) }
          def unmatched_components_to_validate
            unmatched_components.select do |k, _v|
              components_to_validate.include?(k)
            end
          end

          sig { returns(T::Hash[Symbol, T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison)]) }
          def matched_and_unmatched_components
            components = {}
            @matched_and_unmatched_components ||= begin
              components_to_compare.each do |field|
                components[field] = @address_comparison.send(:"#{field}_comparison").sequence_comparison
              end
              components
            end
          end

          sig { returns(T::Array[Symbol]) }
          def components_to_validate
            relevant_components.components_to_validate
          end

          sig { returns(T::Array[Symbol]) }
          def components_to_compare
            relevant_components.components_to_compare
          end

          sig { returns(RelevantComponents) }
          def relevant_components
            @relevant_components ||= RelevantComponents.new(session, candidate, address_comparison)
          end

          sig do
            returns(T::Array[T::Hash[Symbol,
              T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison)]])
          end
          def split_matched_and_unmatched_components
            return @matched_components, @unmatched_components if defined?(@matched_components) &&
              defined?(@unmatched_components)

            @matched_components, @unmatched_components = matched_and_unmatched_components.partition do |_, comparison|
              comparison&.match?
            end.map(&:to_h)
          end

          sig { params(component: Symbol).returns(T.nilable(Symbol)) }
          def field_name(component)
            return component unless component == :street
            return if unmatched_components_to_validate[:street].nil?

            original_street = T.must(unmatched_components_to_validate[:street]).left_sequence.raw_value

            if session.address.address1.to_s.include?(original_street)
              :address1
            elsif session.address.address2.to_s.include?(original_street)
              :address2
            end
          end

          sig { void }
          def log_unknown_field_name
            input_address = session.address.to_h.compact_blank.except(:phone)
            log_error("[AddressValidation] Unable to identify unmatched field name", input_address)
          end
        end
      end
    end
  end
end
