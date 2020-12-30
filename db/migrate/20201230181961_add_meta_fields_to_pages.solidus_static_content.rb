# This migration comes from solidus_static_content (originally 20091219021134)
class AddMetaFieldsToPages < SolidusSupport::Migration[4.2]
  def self.up
    add_column :spree_pages, :meta_keywords, :string
    add_column :spree_pages, :meta_description, :string
  end

  def self.down
  end
end
