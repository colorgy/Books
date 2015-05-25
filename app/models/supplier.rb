class Supplier < ActiveRecord::Base
  has_many :books, foreign_key: :supplier_code, primary_key: :code
  has_many :staffs, class_name: :SupplierStaff,
                    foreign_key: :supplier_code, primary_key: :code
end
