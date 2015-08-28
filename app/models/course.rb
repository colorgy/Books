class Course < ActiveRecord::Base
  scope :simple_search, ->(q) { q.downcase!; where('lower(name) LIKE ? OR lower(lecturer_name) LIKE ? OR lower(ucode) LIKE ?', "%#{q}%", "%#{q}%", "%#{q}%") }

  scope :simple_search, SIMPLE_SEARCH_LAMBDA
  scope :current, -> { where(year: DatetimeService.current_year, term: DatetimeService.current_term) }
  scope :not_current, -> { where.not(year: DatetimeService.current_year, term: DatetimeService.current_term) }
  scope :in_org, ->(org_code) { where(organization_code: (org_code.blank? ? 'public' : org_code)) }
  scope :no_book, -> { joins('LEFT OUTER JOIN "course_books" ON "course_books"."course_ucode" = "courses"."ucode"').where('course_books.id IS NULL') }
  scope :has_book, -> { joins('LEFT OUTER JOIN "course_books" ON "course_books"."course_ucode" = "courses"."ucode"').where('course_books.id IS NOT NULL') }

  belongs_to :lecturer_identity, class_name: :UserIdentity, foreign_key: :lecturer_name, primary_key: :name
  has_many :course_books, primary_key: :ucode, foreign_key: :course_ucode
  has_many :course_book, primary_key: :ucode, foreign_key: :course_ucode
  has_many :book_data, through: :course_book
  has_many :groups

  accepts_nested_attributes_for :course_book, allow_destroy: true, limit: 10

  def self.sync_from(org, year: DatetimeService.current_year, term: DatetimeService.current_term)
    org = org.to_s.upcase
    page = 1
    begin
      # TODO: use an access token to call this request
      response = RestClient.get "#{ENV['CORE_URL']}/api/v1/organizations/#{org}/courses.json?per_page=10000&page=#{page}&fields=year,term,code,name,lecturer,general_code,department_code,required&filter[year]=#{year}&filter[term]=#{term}"
    rescue RestClient::Exception
    else
      Rails.logger.info "Course.sync:  - Getting courses form #{org}"
      last_page = false
      courses_inserts = []
      while last_page == false
        courses = JSON.parse(response)

        last_page = true if response.headers[:link].nil?
        next if courses.blank?

        courses_inserts += courses.map do |c|
          c['name'] && c['name'].gsub!("'", "''")
          c['lecturer'] && c['lecturer'].gsub!("'", "''")
          c['required'] = c['required'].nil? ? "NULL" : c['required']

          "('#{org}-#{c['code']}', '#{org}', #{c['year']}, #{c['term']}, '#{c['code']}', '#{c['name']}', '#{c['lecturer']}', '#{c['general_code']}', '#{c['department_code']}', #{c['required']})"
        end

        if next_match = response.headers[:link] && response.headers[:link].match(/<(?<url>[^<>]+)>; rel="next"/)
          response = RestClient.get next_match[:url]
        else
          last_page = true
        end
      end

      if courses_inserts.length > 0
        Course.where(organization_code: org, year: year, term: term).delete_all
        sql = <<-eof
          INSERT INTO courses (ucode, organization_code, year, term, code, name, lecturer_name, general_code, department_code, required)
          VALUES #{courses_inserts.join(', ')}
        eof
        ActiveRecord::Base.connection.execute(sql)
      end
    end
  end

  def self.sync(year: DatetimeService.current_year, term: DatetimeService.current_term)
    response = RestClient.get "#{ENV['CORE_URL']}/api/v1/organizations?fields=code"
    org_codes = JSON.parse(response).map { |org| org['code'] }

    org_codes.each do |code|
      Rails.logger.info "Course.sync: Syncing #{code} ..."
      sync_from(code, year: year, term: term)
      Rails.logger.info "Course.sync: Sync from #{code} done."
    end
  end

  def current?
    year == DatetimeService.current_year && term == DatetimeService.current_term
  end

  def possible_course_book
    last_year_course = Course.includes(course_book: [:book_data]).find_by(year: year - 1, term: term, general_code: general_code, organization_code: organization_code)
    if last_year_course.present?
      return last_year_course.course_book
    end

    return CourseBook.none
  end

  def book_locked
    course_books.where(locked: true).present?
  end
end
