class AddInvoiceSubsumeTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :invoice_subsume_token, :string
    add_column :users, :invoice_subsume_token_created_at, :datetime
  end
end
