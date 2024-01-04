# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    CandidateTuple = Struct.new(:address_comparison, :position, :candidate) do
      extend T::Sig

      sig { params(other: CandidateTuple).returns(Integer) }
      def <=>(other)
        to_a[0..1] <=> other.to_a[0..1] # only consider address_comparison and position
      end
    end
  end
end
