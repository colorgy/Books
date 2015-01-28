class Book < ActiveRecord::Base
  belongs_to :book_data

  delegate :name, :author, :isbn, :edition, :image_url,
           :publisher, :original_price,
           :to => :book_data, :allow_nil => true

end
