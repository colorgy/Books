require 'rails_helper'

RSpec.describe Course, :type => :model do
  it_should_behave_like "an acts_as_paranoid model"
  it { should belong_to(:book_data) }
  it { should belong_to(:lecturer_identity) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:lecturer_name) }
  it { should validate_presence_of(:year) }
  it { should validate_presence_of(:term) }
  it { should validate_presence_of(:organization_code) }

  let(:prof_identity) { create(:user_identity, identity: 'professor') }

  context "when initialized associated with an identity" do
    subject { prof_identity.courses.build }
    its(:lecturer_name) { is_expected.to eq(prof_identity.name) }
    its(:organization_code) { is_expected.to eq(prof_identity.organization_code) }
    its(:department_code) { is_expected.to eq(prof_identity.department_code) }
    its(:year) { is_expected.to eq((Time.now.month > 6) ? Time.now.year : Time.now.year - 1) }
    its(:term) { is_expected.to eq((Time.now.month > 6) ? 1 : 2) }
  end

  context "when saved with an unknown book" do
    subject(:course) { prof_identity.courses.build(name: 'a course') }
    it "sets the unknown_book_name" do
      course.book_data = nil
      course.book_isbn = 'NEW+>An Unknown Book'
      course.save
      created_course = Course.last

      expect(created_course.book_isbn).to be_nil
      expect(created_course.unknown_book_name).to eq('An Unknown Book')
      expect(created_course.book_name).to eq('An Unknown Book')

      expect(course.book_isbn).to eq('NEW+>An Unknown Book')
    end
  end

  context "when saved with a known book" do
    let(:book_data) { create(:book_data) }
    subject(:course) { prof_identity.courses.build(name: 'a course') }
    it "sets the book_data" do
      course.book_isbn = book_data.isbn
      course.save
      created_course = Course.last

      expect(created_course.book_isbn).to eq(book_data.isbn)
      expect(created_course.unknown_book_name).to be_nil
      expect(created_course.book_name).to eq(book_data.name)

      expect(course.book_isbn).to eq(book_data.isbn)
    end
  end

  context "when saved with blank book_isbn" do
    let(:book_data) { create(:book_data) }
    subject(:course) { prof_identity.courses.build(name: 'a course') }
    it "sets the book_isbn to nil" do
      course.book_isbn = ''
      course.save
      expect(course.book_isbn).to be_nil

      created_course = Course.last
      expect(created_course.book_isbn).to be_nil
    end
  end

  describe "#to_edit" do
    context "with an unknown book" do
      subject(:course) do
        course = prof_identity.courses.build(book_isbn: 'NEW+>An Unknown Book', name: 'A Course')
        course.save
        expect(Course.last.book_isbn).to be_nil
        Course.last.to_edit
      end

      it "sets the book_isbn to the unknown_book_name" do
        expect(subject.book_isbn).to eq('NEW+>An Unknown Book')
      end
    end

    context "with a known book" do
      subject(:course) do
        @book = create(:book_data)
        course = prof_identity.courses.create(book_isbn: @book.isbn)
        course.to_edit
      end

      it "doesn't set the book_isbn to the unknown_book_name" do
        expect(subject.book_isbn).to eq(@book.isbn)
      end
    end
  end

  describe "#book_name" do
    subject(:course) { create(:course, :with_book) }

    it "returns the book's name or the unknown_book_name" do
      expect(course.book_name).to eq course.book_data.name
      course.book_isbn = nil
      course.unknown_book_name = "A Book"
      expect(course.book_name).to eq "A Book"
    end
  end

  describe "#confirm_book!" do
    subject(:course) { create(:course) }

    it "confirms the assigned book" do
      expect do
        course.confirm_book!
      end.to change { course.book_confirmed? }.from(false).to(true)
      course.reload
      expect(course).to be_book_confirmed
    end
  end
end
