class AddUsedCreditIdsToBills < ActiveRecord::Migration
  def change
    add_column :bills, :used_credit_ids, :text
  end
end
