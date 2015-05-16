class RenameBookDatasImageUrl < ActiveRecord::Migration
  def change
    rename_column :book_datas, :image_url, :external_image_url
  end
end
