class CreateTaiwanMobileImgs < ActiveRecord::Migration
  def change
    create_table :taiwan_mobile_imgs do |t|
      t.string :image_url
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :taiwan_mobile_imgs, :users
  end
end
