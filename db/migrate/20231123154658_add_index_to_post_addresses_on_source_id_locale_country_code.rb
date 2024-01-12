# frozen_string_literal: true

class AddIndexToPostAddressesOnSourceIdLocaleCountryCode < ActiveRecord::Migration[7.0]
  def change
    add_index(
      :atlas_engine_post_addresses,
      [:source_id, :locale, :country_code],
      name: "index_atlas_engine_post_addresses_on_srcid_loc_cc",
      if_not_exists: true,
    )
  end
end
