# This migration comes from solidus_static_content (originally 20180305193240)
class UpdateSpreePagePosition < SolidusSupport::Migration[4.2]
  def up
    if column_exists?(:spree_pages, :position)
      change_column :spree_pages, :position, :integer, default: 0
    end
  end

  def down
    if column_exists?(:spree_pages, :position)
      change_column :spree_pages, :position, :boolean, default: false
    end
  end
end
