# frozen_string_literal: true

class CreateAtlasEngineCountryImports < ActiveRecord::Migration[7.0]
  def change
    create_table(:atlas_engine_country_imports, if_not_exists: true) do |t|
      t.string(:country_code, null: false)
      t.string(:state, default: "pending")
      t.timestamps
    end
  end
end
