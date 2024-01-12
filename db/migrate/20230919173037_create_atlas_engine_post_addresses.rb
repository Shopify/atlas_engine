# frozen_string_literal: true

class CreateAtlasEnginePostAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table(:atlas_engine_post_addresses, if_not_exists: true) do |t|
      t.string(:source_id)
      t.string(:locale)
      t.string(:country_code, index: true)
      t.string(:province_code, index: true)
      t.string(:region1)
      t.string(:region2)
      t.string(:region3)
      t.string(:region4)
      t.string(:city, index: true)
      t.string(:suburb)
      t.string(:zip, index: true)
      t.string(:street, index: true)
      t.string(:building_name)
      t.float(:latitude)
      t.float(:longitude)

      t.timestamps
    end
  end
end
