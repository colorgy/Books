class UserCredit < ActiveRecord::Base
  belongs_to :user
  belongs_to :book_data, primary_key: :isbn, foreign_key: :book_isbn

  after_initialize :destroy_if_expired

  def destroy_if_expired
    destroy! if expires_at.present? && Time.now > expires_at
  end
end
