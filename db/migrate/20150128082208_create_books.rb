class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.float :price
      t.belongs_to :book_data, index: true
      
      t.timestamps
    end
  end
end
