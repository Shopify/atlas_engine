# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :country_import, class: "AtlasEngine::CountryImport" do
    trait :pending do
      country_code { "CA" }
      state { "pending" }
    end

    trait :in_progress do
      country_code { "CA" }
      state { "in_progress" }
    end

    trait :complete do
      country_code { "CA" }
      state { "complete" }
    end

    trait :failed do
      country_code { "CA" }
      state { "failed" }
    end

    trait :dk_in_progres do
      country_code { "DK" }
      state { "in_progress" }
    end
  end
end
