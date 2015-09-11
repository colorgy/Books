class CreateGjunForms < ActiveRecord::Migration
  def change
    create_table :gjun_forms do |t|
      t.string :mobile_phone_number
      t.boolean :if_heard_gjun, default: true
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
