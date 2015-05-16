module CanLeadGroups
  extend ActiveSupport::Concern

  included do
    has_many :lead_groups, class_name: Group, foreign_key: :leader_id
  end

  def lead_course_group(course_id, book_id)
    course = Course.find(course_id)
    book = Book.find(book_id)
    group = nil

    ActiveRecord::Base.transaction do
      group = lead_groups.create!(course: course, book: book)
      add_credit!(35)
    end

    group
  end
end
