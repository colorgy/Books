class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :subject
      t.text :content
      t.string :sent_by
      t.string :sent_at
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
