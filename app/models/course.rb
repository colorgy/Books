class Course < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail
  scope :current, ->  { where(year: current_year, term: current_term) }
  scope :not_current, ->  { where.not(year: current_year, term: current_term) }
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
  before_save :set_book_before_save, :update_version_count
  after_save :set_book_after_save

  def self.current_year
    (Time.now.month > 6) ? Time.now.year : Time.now.year - 1
  end

  def self.current_term
    (Time.now.month > 6) ? 1 : 2
  end

  def self.search(query, organization_code: nil, year: nil, term: nil)
    query.downcase!

    scope = all
    scope = scope.where(organization_code: organization_code) if organization_code
    scope = scope.where(year: year) if year
    scope = scope.where(term: term) if term

    courses = scope.where("(lower(name) LIKE ? OR lower(lecturer_name) LIKE ?)", "%#{query}%", "%#{query}%").limit(100)

    if courses.empty?
      queries = query.split(' ')
      courses = scope.where("(lower(name) LIKE ? AND lower(lecturer_name) LIKE ?)", "%#{queries[0]}%", "%#{queries[1]}%").limit(100)
      courses = scope.where("(lower(name) LIKE ? AND lower(lecturer_name) LIKE ?)", "%#{queries[1]}%", "%#{queries[0]}%").limit(100) if courses.empty?
    end

    return courses
  end

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

  def current?
    year == Course.current_year && term == Course.current_term
  end

  def to_edit
    set_book_after_save
    self
  end

  private

  def set_default_values
    self.year ||= Course.current_year
    self.term ||= Course.current_term
    self.organization_code = lecturer_identity.organization_code if organization_code.blank? && lecturer_identity
    self.department_code = lecturer_identity.department_code if department_code.blank? &&lecturer_identity
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

  def update_version_count
    self.version_count = versions.count + 1
  end
end
