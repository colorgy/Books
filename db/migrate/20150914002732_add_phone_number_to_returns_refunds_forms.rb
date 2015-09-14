class AddPhoneNumberToReturnsRefundsForms < ActiveRecord::Migration
  def change
    add_column :returns_refunds_forms, :phone_number, :string
  end
end
