require 'rails_helper'

RSpec.describe CourseBook, type: :model do
  it { should belong_to(:course) }
  it { should belong_to(:book_data) }
end
