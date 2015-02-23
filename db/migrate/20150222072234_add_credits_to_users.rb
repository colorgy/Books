class AddCreditsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :credits, :integer, null: false, default: 0
  end
end
