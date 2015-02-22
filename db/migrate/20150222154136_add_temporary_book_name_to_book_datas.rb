class AddTemporaryBookNameToBookDatas < ActiveRecord::Migration
  def change
    add_column :book_datas, :temporary_book_name, :string
  end
end
