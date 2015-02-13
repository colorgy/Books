class Book < ActiveRecord::Base
  belongs_to :data, class_name: :BookData, foreign_key: :book_data_isbn, primary_key: :isbn

  delegate :name, :author, :isbn, :edition, :image_url,
           :publisher, :original_price, :courses,
           to: :data, allow_nil: true

  validates :data, presence: true
end
