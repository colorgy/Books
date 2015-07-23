class AddInternalCodeToBookDatas < ActiveRecord::Migration
  def change
    add_column :book_datas, :internal_code, :string
  end
end
