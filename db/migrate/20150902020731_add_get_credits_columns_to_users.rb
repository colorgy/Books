class AddGetCreditsColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tutorabc_check_credits, :boolean, default: false
    add_column :users, :share_colorgy_books_credits, :boolean, default: false
    add_column :users, :taiwan_mobile_credits, :boolean, default: false
  end
end
