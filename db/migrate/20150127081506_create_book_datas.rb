class CreateBookDatas < ActiveRecord::Migration
  def change
    create_table :book_datas do |t|
      t.string :isbn
      t.string :name
      t.string :edition
      t.string :author
      t.string :image_url
      t.string :publisher
      t.float :price

      t.timestamps
    end
  end
end
