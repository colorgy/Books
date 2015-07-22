class AllowNullGroupCodeValueForOrders < ActiveRecord::Migration
  def change
    change_column :orders, :group_code, :string, null: true
  end
end
