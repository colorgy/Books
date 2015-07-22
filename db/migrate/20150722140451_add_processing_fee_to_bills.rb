class AddProcessingFeeToBills < ActiveRecord::Migration
  def change
    add_column :bills, :processing_fee, :integer, null: false, default: 0
    change_column :bills, :used_credits, :integer, null: false, default: 0
  end
end
