class AddPaymentCodeToBills < ActiveRecord::Migration
  def change
    add_column :bills, :payment_code, :string
  end
end
