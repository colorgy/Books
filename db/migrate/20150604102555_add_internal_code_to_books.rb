class AddInternalCodeToBooks < ActiveRecord::Migration
  def change
    add_column :books, :internal_code, :string
    add_index :books, :internal_code
  end
end
