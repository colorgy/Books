class Course < ActiveRecord::Base
  belongs_to :book_data,
              class_name: :BookData, foreign_key: :book_isbn, primary_key: :isbn
  belongs_to :user

  scope :confirmed, -> { where(self.confirmed?) }

  def confirm!(user)
    self.confirmed_at = Time.now
    self.user_id = user.id
    self.save
  end

  def confirmed?
    !self.confirmed_at.nil?
  end
end
