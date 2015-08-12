class AddAdditionalItemsToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :additional_items, :text
  end
end
