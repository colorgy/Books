class AddAttachmentImageUrlToTaiwanMobileImgs < ActiveRecord::Migration
  def self.up
    change_table :taiwan_mobile_imgs do |t|
      t.attachment :image_url
    end
  end

  def self.down
    remove_attachment :taiwan_mobile_imgs, :image_url
  end
end
