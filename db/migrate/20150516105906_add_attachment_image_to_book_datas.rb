class AddAttachmentImageToBookDatas < ActiveRecord::Migration
  def self.up
    change_table :book_datas do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :book_datas, :image
  end
end
