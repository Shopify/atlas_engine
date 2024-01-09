# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module DatastoreBase
      extend T::Sig
      extend T::Helpers
      interface!

      sig { abstract.returns(Token::Sequence) }
      def fetch_city_sequence; end

      sig { abstract.returns(T::Array[Token::Sequence]) }
      def fetch_street_sequences; end

      sig { abstract.returns(T::Array[Candidate]) }
      def fetch_full_address_candidates; end

      sig { abstract.returns(T::Hash[T.untyped, T.untyped]) }
      def validation_response; end

      sig { abstract.returns(ValidationTranscriber::AddressParsings) }
      def parsings; end
    end
  end
end
