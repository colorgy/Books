class AddOutOfStockToBooks < ActiveRecord::Migration
  def change
    add_column :books, :out_of_stock, :boolean, default: false
  end
end
