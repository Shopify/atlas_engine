# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module ImportLogHelper
      extend T::Sig
      include LogHelper

      TEST_TIMESTAMP = "timestamp"

      sig do
        params(
          country_import: CountryImport,
          message: String,
          category: T.nilable(Symbol),
          additional_params: T::Hash[T.untyped, T.untyped],
          notify: T::Boolean,
        ).void
      end
      def import_log_info(country_import:, message:, category: :progress, additional_params: {}, notify: false)
        log_info(message, additional_params)
        event = create_event(country_import, message, category, additional_params)
        send_notification(event) if event && notify
      end

      sig do
        params(
          country_import: CountryImport,
          message: String,
          additional_params: T.nilable(T::Hash[T.untyped, T.untyped]),
        ).void
      end
      def import_log_error(country_import:, message:, additional_params: {})
        log_error(message, T.must(additional_params))
        event = create_event(country_import, message, :error, additional_params)
        send_notification(event) if event
      end

      private

      sig do
        params(
          country_import: CountryImport,
          message: String,
          category: T.nilable(Symbol),
          additional_params: T.nilable(T::Hash[T.untyped, T.untyped]),
        )
          .returns(T.nilable(Event))
      end
      def create_event(country_import, message, category, additional_params = nil)
        Event.create(
          country_import_id: country_import.id,
          message: message,
          category: category,
          additional_params: additional_params.presence,
        )
      end

      sig { params(event: Event).void }
      def send_notification(event)
        AtlasEngine.address_importer_notifier.constantize.instance.notify(event: event)
      end
    end
  end
end
