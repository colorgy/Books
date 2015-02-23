class ChangeOrginalPriceFormatToInteger < ActiveRecord::Migration
  def up
    change_column :book_datas, :original_price, :integer
  end

  def down
    change_column :book_datas, :original_price, :float
  end
end
