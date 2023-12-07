# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Zip
          class ZipBase < Predicate
            abstract!

            sig { returns(T.nilable(T::Boolean)) }
            def concerning?
              return false unless @cache.country.country?
              return false unless @cache.country.has_zip?
              return false unless @cache.country.zip_required?

              true
            end
          end
        end
      end
    end
  end
end
