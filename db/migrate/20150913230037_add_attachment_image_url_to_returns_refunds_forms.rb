class AddAttachmentImageUrlToReturnsRefundsForms < ActiveRecord::Migration
  def self.up
    change_table :returns_refunds_forms do |t|
      t.attachment :image_url
    end
  end

  def self.down
    remove_attachment :returns_refunds_forms, :image_url
  end
end
