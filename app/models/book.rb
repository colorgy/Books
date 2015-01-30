class Book < ActiveRecord::Base
  belongs_to :data, class_name: :BookData, foreign_key: :book_data_id

  delegate :name, :author, :isbn, :edition, :image_url,
           :publisher, :original_price,
           to: :data, allow_nil: true

  validates :data, presence: true
end
