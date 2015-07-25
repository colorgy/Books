class SupplierStaff < ActiveRecord::Base
  devise :database_authenticatable, :lockable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :supplier, foreign_key: :supplier_code, primary_key: :code

  delegate :name, to: :supplier, prefix: true, allow_nil: true

  validates :username, :email, :name, presence: true

  def company_name
    supplier_name
  end

  def books
    supplier.book_collection
  end

  def groups
    supplier.group_collection
  end
end
