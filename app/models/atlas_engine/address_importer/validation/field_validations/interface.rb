# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module Validation
      module FieldValidations
        module Interface
          extend T::Sig
          extend T::Helpers
          include Kernel

          interface!

          sig do
            abstract.params(
              address: AddressImporter::Validation::Wrapper::AddressStruct,
              allow_partial_zip: T::Boolean,
            ).void
          end
          def initialize(address:, allow_partial_zip: false); end

          sig { abstract.returns(T::Array[String]) }
          def validation_errors; end
        end
      end
    end
  end
end
