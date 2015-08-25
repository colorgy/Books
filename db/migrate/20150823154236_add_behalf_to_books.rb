class AddBehalfToBooks < ActiveRecord::Migration
  def change
    add_column :books, :behalf, :boolean, null: false, default: false
  end
end
