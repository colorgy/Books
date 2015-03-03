class Book < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :data, class_name: :BookData, foreign_key: :isbn, primary_key: :isbn

  delegate :name, :author, :isbn, :edition, :image_url,
           :publisher, :original_price, :courses,
           to: :data, allow_nil: true

  validates :data, presence: true
end
