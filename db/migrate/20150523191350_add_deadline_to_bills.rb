class AddDeadlineToBills < ActiveRecord::Migration
  def change
    add_column :bills, :deadline, :datetime, null: false, default: Time.now
    add_index :bills, :deadline
    change_column :bills, :deadline, :datetime, null: false, default: nil
  end
end
