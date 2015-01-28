class Course < ActiveRecord::Base
  belongs_to :book_data,
              class_name: :BookData, foreign_key: :book_isbn, primary_key: :isbn
  belongs_to :user

  scope :confirmed, -> { where(confirmed: true) }

  def confirm!(user)
    if self.book_data.nil? || self.confirmed == true
      raise Exception.new "Book Data hasn't assigned"
    else
      self.confirmed = true
      self.user_id = user.id
      self.save 
    end
  end
end
