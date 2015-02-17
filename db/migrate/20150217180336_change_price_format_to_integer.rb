class ChangePriceFormatToInteger < ActiveRecord::Migration
  def change
    change_column :bills, :price, :integer
    change_column :bills, :amount, :integer
    change_column :orders, :price, :integer
    change_column :books, :price, :integer
  end
end
