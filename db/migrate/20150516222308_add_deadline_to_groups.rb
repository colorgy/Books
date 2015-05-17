class AddDeadlineToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :state, :string, null: false, default: 'grouping'
    add_column :groups, :public, :boolean, null: false, default: false
    add_column :groups, :deadline, :datetime
    add_column :groups, :pickup_datetime, :datetime
    add_index :groups, :state
    add_index :groups, :public
    add_index :groups, :deadline
    change_column :groups, :course_id, :integer, null: true
    rename_column :groups, :mobile, :recipient_mobile
    remove_column :groups, :batch
  end
end
