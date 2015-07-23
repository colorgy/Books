class RemoveDefaultValueForBillsDeadline < ActiveRecord::Migration
  def change
    change_column :bills, :deadline, :datetime, null: false, default: nil
  end
end
