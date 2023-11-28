# typed: true
# frozen_string_literal: true

module AtlasEngine
  class CountryProfileSubsetBase
    extend T::Sig

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    attr_reader :attributes

    sig { params(hash: T::Hash[T.untyped, T.untyped]).void }
    def initialize(hash:)
      @attributes = hash

      attributes.keys.each do |key|
        define_singleton_method(key.to_s) do
          @attributes[key]
        end unless respond_to?(key.to_s)
      end
    end
  end
end
