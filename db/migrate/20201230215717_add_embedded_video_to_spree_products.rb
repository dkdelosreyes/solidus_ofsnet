class AddEmbeddedVideoToSpreeProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_products, :embedded_video, :text
  end
end
