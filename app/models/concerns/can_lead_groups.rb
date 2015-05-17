module CanLeadGroups
  extend ActiveSupport::Concern

  included do
    has_many :lead_groups, class_name: Group, foreign_key: :leader_id
  end

  def lead_new_group(book, course: nil, org_code: nil)
    book = Book.find(book) if book.is_a?(Integer)
    group = nil

    course = Course.find(course) if course.is_a?(Integer)
    ActiveRecord::Base.transaction do
      group = lead_groups.create!(book: book, course: course, organization_code: org_code, public: true)
    end

    group
  end

  def lead_course_group(course_id, book_id)
    book = Book.find(book_id)
    group = nil

    course = Course.find(course_id)
    ActiveRecord::Base.transaction do
      group = lead_groups.create!(course: course, book: book)
      add_credit!(35)
    end

    group
  end
end
