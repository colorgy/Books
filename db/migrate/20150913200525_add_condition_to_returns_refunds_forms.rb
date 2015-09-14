class AddConditionToReturnsRefundsForms < ActiveRecord::Migration
  def change
    add_column :returns_refunds_forms, :condition, :string
  end
end
