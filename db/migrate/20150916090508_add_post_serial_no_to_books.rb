class AddPostSerialNoToBooks < ActiveRecord::Migration
  def change
    add_column :books, :post_serial_no, :string
  end
end
