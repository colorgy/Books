class CreatePickupSelections < ActiveRecord::Migration
  def change
    create_table :pickup_selections_dates do |t|
      t.string :organization_code
      t.string :batch
      t.string :selection

      t.timestamps
    end
    add_index :pickup_selections_dates, :organization_code, unique: false
    add_index :pickup_selections_dates, :batch, unique: false

    create_table :pickup_selections_times do |t|
      t.string :organization_code
      t.string :batch
      t.string :selection

      t.timestamps
    end
    add_index :pickup_selections_times, :organization_code, unique: false
    add_index :pickup_selections_times, :batch, unique: false

    create_table :pickup_selections_points do |t|
      t.string :organization_code
      t.string :batch
      t.string :selection

      t.timestamps
    end
    add_index :pickup_selections_points, :organization_code, unique: false
    add_index :pickup_selections_points, :batch, unique: false
  end
end
