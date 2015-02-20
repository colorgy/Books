class AddPaidAtToBills < ActiveRecord::Migration
  def change
    add_column :bills, :paid_at, :datetime
  end
end
