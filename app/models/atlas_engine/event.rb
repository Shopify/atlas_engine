# typed: true
# frozen_string_literal: true

module AtlasEngine
  class Event < ApplicationRecord
    include ActiveModel::Validations

    belongs_to :country_import, class_name: "AtlasEngine::CountryImport"
    validates :message, presence: true
    enum category: { progress: 0, error: 1, invalid_address: 2 }
  end
end
