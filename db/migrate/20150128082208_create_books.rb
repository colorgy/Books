class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :provider
      t.float :price, null: false
      t.belongs_to :book_data, index: true

      t.timestamps
    end
  end
end
