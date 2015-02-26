class AddBatchToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :batch, :string, null: false, default: '_null_'
    add_index :groups, :batch, unique: false
  end
end
