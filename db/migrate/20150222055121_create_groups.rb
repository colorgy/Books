class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :code, null: false
      t.integer :leader_id, null: false
      t.integer :course_id, null: false
      t.integer :book_id, null: false

      t.timestamps
    end
    add_index :groups, :code, unique: true
    add_index :groups, :leader_id, unique: false
  end
end
