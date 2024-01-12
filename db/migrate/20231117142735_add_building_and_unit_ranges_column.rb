# frozen_string_literal: true

class AddBuildingAndUnitRangesColumn < ActiveRecord::Migration[7.0]
  def change
    add_column(:atlas_engine_post_addresses, :building_and_unit_ranges, :json)
  end
end
