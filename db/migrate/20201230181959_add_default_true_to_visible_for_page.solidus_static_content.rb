# This migration comes from solidus_static_content (originally 20090814142845)
class AddDefaultTrueToVisibleForPage < SolidusSupport::Migration[4.2]
  def self.up
    change_column :spree_pages, :visible, :boolean, :default=> true
  end

  def self.down
  end
end