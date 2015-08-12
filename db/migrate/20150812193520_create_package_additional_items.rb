class CreatePackageAdditionalItems < ActiveRecord::Migration
  def change
    create_table :package_additional_items do |t|
      t.string :name
      t.integer :price
      t.string :url
      t.string :external_image_url

      t.timestamps null: false
    end
  end
end
