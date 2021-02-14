class CreateSpreeFacebookPages < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_facebook_pages do |t|
      t.string   :name
      t.string   :facebook_page_id
      t.string   :user_access_token
      t.string   :page_access_token
      t.integer  :user_id
      t.datetime :expired_at
      t.jsonb    :payload, default: {}

      t.timestamps

      t.index [ :facebook_page_id ], unique: true
      t.index [ :user_id ]
    end
  end
end
