class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name, null: false
      t.string :code, null: false

      t.timestamps null: false
    end
    add_index :suppliers, :code, unique: true
  end
end
