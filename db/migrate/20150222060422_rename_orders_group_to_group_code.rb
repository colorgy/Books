class RenameOrdersGroupToGroupCode < ActiveRecord::Migration
  def change
    rename_column :orders, :group, :group_code
  end
end
