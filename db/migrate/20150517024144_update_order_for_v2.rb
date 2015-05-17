class UpdateOrderForV2 < ActiveRecord::Migration
  def change
    remove_column :orders, :batch
    remove_column :orders, :organization_code
    remove_column :orders, :course_id
  end
end
