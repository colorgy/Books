class AddDeletedAtToBooks < ActiveRecord::Migration
  def change
    add_column :books, :deleted_at, :datetime
    add_index :books, :deleted_at
  end
end
