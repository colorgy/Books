class AddRecipientNameToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :recipient_name, :string
  end
end
