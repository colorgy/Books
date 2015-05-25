class SupplierStaff < ActiveRecord::Base
  devise :database_authenticatable, :lockable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :supplier, foreign_key: :supplier_code, primary_key: :code
  has_many :books, foreign_key: :supplier_code, primary_key: :supplier_code

  delegate :name, to: :supplier, prefix: true, allow_nil: true

  def company_name
    supplier_name
  end
end
