# frozen_string_literal: true

class CreateAtlasEngineEventsTable < ActiveRecord::Migration[7.0]
  def change
    create_table(:atlas_engine_events, if_not_exists: true) do |t|
      t.bigint(:country_import_id, null: false, index: true)
      t.text(:message)
      t.json(:additional_params)
      t.integer(:category, default: 0)
      t.timestamps
    end
  end
end
