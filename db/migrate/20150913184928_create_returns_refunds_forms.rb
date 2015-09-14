class CreateReturnsRefundsForms < ActiveRecord::Migration
  def change
    create_table :returns_refunds_forms do |t|
      t.boolean :if_delivered, default: true
      t.string :bill_uuid
      t.string :account_bank_code
      t.string :account_number
      t.text :reason
      t.integer :status, default: 1
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
