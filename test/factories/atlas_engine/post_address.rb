# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :post_address, class: "AtlasEngine::PostAddress" do
    locale { "EN" }
    country_code { "CA" }
    province_code { "ON" }
    region1 { "Ontario" }
    region2 { "Ottawa" }
    region3 { nil }
    region4 { nil }
    city { ["Ottawa"] }
    suburb { nil }
    zip { "K2P 1L4" }
    street { nil }
    building_name { nil }
    latitude { 45.4210 }
    longitude { -75.6930 }

    factory :gb_address do
      locale { "en-GB" }
      country_code { "GB" }
      province_code { "ENG" }
      city { ["Plymouth"] }
      zip { "PL1 1AE" }
    end

    factory :ca_address do
      country_code { "CA" }
      province_code { "BC" }
      city { ["Vancouver"] }
      zip { "V5K 0A4" }
    end

    factory :ch_address do
      country_code { "CH" }
      province_code { nil }
      zip { "6344" }
      city { ["Meierskappel"] }
      street { "Sagistrasse" }

      trait :de do
        locale { "de" }
      end

      trait :fr do
        locale { "fr" }
      end

      trait :it do
        locale { "it" }
      end
    end

    factory :jp_address do
      country_code { "JP" }
      province_code { "JP-13" }
      zip { "123-8517" }
      latitude { 35.778 }
      longitude { 139.769 }

      trait :en_full do
        locale { "EN" }
        region1 { "Kanto" }
        region2 { "Tokyo" }
        region3 { "Adachi" }
        city { ["Kohoku"] }
      end

      trait :ja_full do
        locale { "JA" }
        region1 { "関東地方" }
        region2 { "東京都" }
        region3 { "足立区" }
        city { ["江北"] }
      end
    end

    factory :illinois_address do
      locale { "en-US" }
      country_code { "US" }
      province_code { "IL" }
      city { ["Chicago"] }
      zip { "60007" }

      trait :with_street do
        street { "North Lincoln Avenue" }
      end

      trait :with_location do
        latitude { 41.3498 }
        longitude { -87.5322 }
      end
    end

    factory :california_address do
      locale { "en-US" }
      country_code { "US" }
      province_code { "CA" }
      city { ["Los Angeles"] }
      zip { "90001" }

      trait :with_street do
        street { "Ocean Avenue" }
      end

      trait :with_location do
        latitude { 34.0241 }
        longitude { -118.5101 }
      end
    end

    factory :massachusetts_address do
      locale { "en-US" }
      country_code { "US" }
      province_code { "MA" }
      city { ["Dorchester", "Boston", "Uphams Corner"] }
      zip { "02125" }

      trait :with_street do
        street { "Pleasant St" }
      end
    end
  end
end
