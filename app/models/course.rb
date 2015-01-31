class Course < ActiveRecord::Base
  scope :book_confirmed, -> { where(self.confirmed?) }

  belongs_to :book_data, class_name: :BookData, foreign_key: :book_isbn, primary_key: :isbn
  belongs_to :lecturer_identity, class_name: :UserIdentity, foreign_key: :lecturer_name, primary_key: :name

  validates :name, presence: true
  validates :lecturer_name, presence: true

  def book_name
    (book_data && book_data.name) || unknown_book_name
  end

  def confirm_book!
    self.book_confirmed_at = Time.now
    save!
  end

  def book_confirmed?
    !book_confirmed_at.blank?
  end
end
