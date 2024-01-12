# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module ImportEventsNotifier
      class Notifier < Base
        extend T::Sig
        extend T::Helpers

        include Singleton

        sig do
          override.params(
            event: Event,
          ).void
        end
        def notify(event:)
          # do nothing,
          # The Host application can define its own notifier by configuring
          # AtlasEngine.address_importer_notifier = MyCustomNotifier
        end
      end
    end
  end
end
