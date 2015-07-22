class UserCartItem < ActiveRecord::Base
  scope :includes_default, -> { includes(direct_group: [:leader, :course, :book], direct_book: [:data], direct_course: []) }
  belongs_to :user, counter_cache: :cart_items_count

  belongs_to :direct_group, class_name: :Group, foreign_key: :item_code, primary_key: :code
  belongs_to :direct_book, class_name: :Book, foreign_key: :item_code, primary_key: :id
  belongs_to :direct_course, class_name: :Course, foreign_key: :course_ucode, primary_key: :ucode

  validates :user, :item_type, :item_code, :quantity, presence: true
  validates :quantity, inclusion: 1..100
  validates :item_type, inclusion: { in: %w(group package) }

  # Return the corresponding group
  def group
    return nil if item_type != 'group'
    direct_group
  end

  # Return the corresponding book
  def book
    return direct_book if item_type == 'book' || item_type == 'package'
    group && group.book
  end

  # Return the corresponding course
  def course
    return direct_course if direct_course.present?
    group && group.course
  end

  # Return the corresponding item (group or book)
  def item
    case item_type
    when 'group'
      group
    end
  end

  # def item_price
  #   price * quantity
  # end
end
