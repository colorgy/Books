class ChangeBillIdToBillUuidOfOrders < ActiveRecord::Migration
  def change
    add_column :orders, :bill_uuid, :string
    remove_column :orders, :bill_id
    add_index :orders, :bill_uuid
  end
end
