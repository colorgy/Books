require 'rails_helper'

RSpec.describe Book, :type => :model do
  it_should_behave_like "an acts_as_paranoid model"
  it { should belong_to(:data) }
  it { should validate_presence_of(:data) }

#   context "#for_org" do
#     # NTUST                     C
#     # NTU           B(price1)
#     # PUBLIC  A     B(price2)
#     let(:book_a) { create(:book) }
#     let(:book_b_1) { create(:book, organization_code: 'NTU') }
#     let(:book_b_2) { create(:book, data: book_b_1.data ) }
#     let(:book_c) { create(:book, organization_code: 'NTUST') }

#     it "select public book when no book in organization" do
#       expect(Book.for_org('NTU').find_by(isbn: book_a.isbn)).to eq(book_a)
#     end

#     it "select book in org first" do
#       book_b_2
#       expect(Book.for_org('NTU').find_by(isbn: book_b_1.isbn)).to eq(book_b_1)
#       expect(Book.for_org('NTUST').find_by(isbn: book_b_1.isbn)).to eq(book_b_2)
#       expect(Book.for_org(nil).find_by(isbn: book_b_1.isbn)).to eq(book_b_2)
#     end

#     it "cannot select org specific book without public book" do
#       expect(Book.for_org(nil).find_by(isbn: book_c.isbn)).to be_nil
#       expect(Book.for_org('NTU').find_by(isbn: book_c.isbn)).to be_nil
#       expect(Book.for_org('NTUST').find_by(isbn: book_c.isbn)).to eq(book_c)
#     end
#   end
end
