# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module AbstractAddress
      extend T::Sig
      extend T::Helpers
      include Kernel
      abstract!
      ComponentType = T.type_alias { T.nilable(String) }

      sig { abstract.returns(ComponentType) }
      def address1; end

      sig { abstract.returns(ComponentType) }
      def address2; end

      sig { abstract.returns(ComponentType) }
      def city; end

      sig { abstract.returns(ComponentType) }
      def province_code; end

      sig { abstract.returns(ComponentType) }
      def phone; end

      sig { abstract.returns(ComponentType) }
      def country_code; end

      sig { abstract.returns(ComponentType) }
      def zip; end

      sig { abstract.returns(T::Hash[Symbol, String]) }
      def to_h; end

      sig { abstract.returns(T.untyped) }
      def context; end

      sig { overridable.returns(T::Enumerable[Symbol]) }
      def keys = to_h.keys # rubocop:disable Rails/Delegate

      sig { overridable.params(key: Symbol).returns(T.untyped) }
      def [](key) = to_h[key] # rubocop:disable Rails/Delegate
    end

    TAddress = T.type_alias { AbstractAddress }
  end
end
