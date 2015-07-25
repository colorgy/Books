class Supplier < ActiveRecord::Base
  has_many :books, foreign_key: :supplier_code, primary_key: :code
  has_many :groups, foreign_key: :supplier_code, primary_key: :code
  has_many :staffs, class_name: :SupplierStaff,
                    foreign_key: :supplier_code, primary_key: :code

  validates :name, :code, presence: true
  validates :code, uniqueness: true

  def book_collection
    if is_root
      Book.all
    else
      books
    end
  end

  def group_collection
    if is_root
      Group.all
    else
      groups
    end
  end

  def package_collection
    if deal_package || is_root
      Package.all
    else
      Package.none
    end
  end
end
