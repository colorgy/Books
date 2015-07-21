module CanLeadGroups
  extend ActiveSupport::Concern

  included do
    has_many :lead_groups, class_name: Group, foreign_key: :leader_id
  end

  def lead_group(group)
    # setup the group for the leader
    group.leader_id = id
    group.public = true

    # check and initalize attributes of the group
    if group.book && group.book.organization_code.present?
      group.organization_code ||= group.book.organization_code
      raise if group.organization_code != group.book.organization_code
    end

    # save the group
    group.save!

    group
  end

  # Deprecated
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
