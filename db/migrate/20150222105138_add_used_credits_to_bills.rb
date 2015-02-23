class AddUsedCreditsToBills < ActiveRecord::Migration
  def change
    add_column :bills, :used_credits, :integer
  end
end
