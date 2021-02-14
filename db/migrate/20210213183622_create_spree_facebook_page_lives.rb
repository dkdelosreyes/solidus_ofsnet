class CreateSpreeFacebookPageLives < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_facebook_page_lives do |t|
      t.string   :video_id
      t.integer  :state, default: 0
      t.integer  :facebook_page_id
      t.datetime :creation_time
      t.jsonb    :payload, default: {}

      t.timestamps

      t.index [ :state ]
      t.index [ :facebook_page_id ]
    end
  end
end
