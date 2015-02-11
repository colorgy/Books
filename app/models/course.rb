class Course < ActiveRecord::Base
  acts_as_paranoid
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  belongs_to :book_data, class_name: :BookData, foreign_key: :book_isbn, primary_key: :isbn
  belongs_to :lecturer_identity, class_name: :UserIdentity, foreign_key: :lecturer_name, primary_key: :name

  validates :name, presence: true
  validates :year, presence: true
  validates :term, presence: true
  validates :lecturer_name, presence: true
  validates :organization_code, presence: true

  after_initialize :set_default_values
  before_save :set_book_before_save
  after_save :set_book_after_save

  def book_name
    (book_data && book_data.name) || unknown_book_name
  end

  def confirm!
    self.confirmed_at = Time.now
    save!
  end

  def confirmed?
    !confirmed_at.blank?
  end

  def to_edit
    set_book_after_save
    self
  end

  private

  def set_default_values
    self.year ||= (Time.now.month > 6) ? Time.now.year : Time.now.year - 1
    self.term ||= (Time.now.month > 6) ? 1 : 2
    self.organization_code = lecturer_identity.organization_code if lecturer_identity
    self.department_code = lecturer_identity.department_code if lecturer_identity
  end

  def set_book_before_save
    if book_data.blank? && !book_isbn.blank?
      self.unknown_book_name = book_isbn.gsub('NEW+>', '')
      self.book_isbn = nil
    elsif book_isbn.blank?
      self.book_isbn = nil
    end
  end

  def set_book_after_save
    return unless book_isbn.blank? && !unknown_book_name.blank?
    self.book_isbn = 'NEW+>' + unknown_book_name
  end
end
