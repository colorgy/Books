class AddBuyableToBooks < ActiveRecord::Migration
  def change
    add_column :books, :buyable, :boolean, null: false, default: true
  end
end
