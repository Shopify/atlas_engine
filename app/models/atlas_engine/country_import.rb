# typed: false
# frozen_string_literal: true

module AtlasEngine
  class CountryImport < ApplicationRecord
    class InterruptionError < StandardError; end
    has_many :events, dependent: :destroy, class_name: "AtlasEngine::Event"

    PAGE_SIZE = 10

    validates :country_code, presence: true

    state_machine initial: :pending do
      event :start do
        transition pending: :in_progress
      end

      event :complete do
        transition in_progress: :complete
      end

      event :interrupt do
        transition [:pending, :in_progress, :failed] => :failed
      end

      state :in_progress do
        validate :no_imports_in_progress?
      end
    end

    sig { returns(T::Boolean) }
    def detected_invalid_addresses?
      events.where(category: :invalid_address).any?
    end

    private

    def no_imports_in_progress?
      if CountryImport.where(country_code: country_code).with_state(:in_progress).where.not(id: id).any?
        errors.add(:state, "cannot be in progress when there is another import already in progress")
      end
    end
  end
end
