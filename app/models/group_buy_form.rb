class GroupBuyForm < ActiveRecord::Base
  belongs_to :user
  belongs_to :book_data, foreign_key: :book_isbn, primary_key: :isbn
  belongs_to :course
end
