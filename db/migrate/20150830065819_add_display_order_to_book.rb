class AddDisplayOrderToBook < ActiveRecord::Migration
  def change
    add_column :books, :display_order, :integer, null: false, default: 100
    add_index :books, :display_order
  end
end
