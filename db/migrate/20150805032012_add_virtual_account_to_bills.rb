class AddVirtualAccountToBills < ActiveRecord::Migration
  def change
    add_column :bills, :virtual_account, :string
  end
end
