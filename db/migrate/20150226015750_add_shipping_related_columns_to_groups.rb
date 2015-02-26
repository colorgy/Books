class AddShippingRelatedColumnsToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :shipped_at, :datetime
    add_index :groups, :shipped_at, unique: false
    add_column :groups, :received_at, :datetime
    add_index :groups, :received_at, unique: false
    add_column :groups, :pickup_point, :string
    add_column :groups, :pickup_date, :string
    add_column :groups, :pickup_time, :string
    add_column :groups, :data, :text
  end
end
