# typed: true
# frozen_string_literal: true

module AtlasEngine
  module HandlesInterruption
    extend ActiveSupport::Concern
    include LogHelper
    include Kernel

    included do
      def exit_if_interrupted!(import)
        import_state = Rails.cache.fetch("country_import:#{import.id}:state", expires_in: 5.seconds) do
          import.reload.state
        end

        return unless import_state == "failed"

        raise CountryImport::InterruptionError, "Import interrupted at #{Time.current.utc.to_fs}"
      end
    end
  end
end
