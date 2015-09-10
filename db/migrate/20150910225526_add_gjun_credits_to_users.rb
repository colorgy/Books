class AddGjunCreditsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gjun_credits, :boolean, default: false
  end
end
