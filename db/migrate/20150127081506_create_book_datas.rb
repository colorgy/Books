class CreateBookDatas < ActiveRecord::Migration
  def change
    create_table :book_datas do |t|
      t.string :isbn
      t.string :name, null: false
      t.string :edition
      t.string :author
      t.string :image_url
      t.string :url
      t.string :publisher
      t.string :original_url
      t.float  :original_price

      t.timestamps
    end

    add_index :book_datas, :isbn, unique: true
  end
end
