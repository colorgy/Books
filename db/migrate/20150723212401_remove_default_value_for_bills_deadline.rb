class RemoveDefaultValueForBillsDeadline < ActiveRecord::Migration
  def change
    change_column_default :bills, :deadline, nil
  end
end
