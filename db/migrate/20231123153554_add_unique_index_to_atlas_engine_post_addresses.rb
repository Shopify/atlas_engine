# frozen_string_literal: true

class AddUniqueIndexToAtlasEnginePostAddresses < ActiveRecord::Migration[7.0]
  def change
    add_index(
      :atlas_engine_post_addresses,
      [:province_code, :zip, :street, :city, :locale],
      name: "index_atlas_engine_post_addresses_on_pc_zp_st_ct_lc",
      unique: true,
      length: { province_code: 10, zip: 10, street: 100, city: 255, locale: 10 },
      if_not_exists: true,
    )
  end
end
