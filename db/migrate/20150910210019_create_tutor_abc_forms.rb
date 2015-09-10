class CreateTutorAbcForms < ActiveRecord::Migration
  def change
    create_table :tutor_abc_forms do |t|
      t.string :mobile_phone_number
      t.boolean :if_heard_tutor_abc, default: true
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
