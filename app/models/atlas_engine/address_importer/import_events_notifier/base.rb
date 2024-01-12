# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module ImportEventsNotifier
      class Base
        extend T::Sig
        extend T::Helpers
        abstract!

        class << self
          extend T::Sig

          sig { returns(T.untyped) }
          def instance
            T.unsafe(self).new
          end
        end

        sig { params(client: T.untyped).void }
        def initialize(client: nil)
          @client = client
        end

        sig do
          abstract.params(
            event: Event,
          ).void
        end
        def notify(event:); end
      end
    end
  end
end
