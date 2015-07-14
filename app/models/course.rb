class Course < ActiveRecord::Base
  scope :current, -> { where(year: DatetimeService.current_year, term: DatetimeService.current_term) }
  scope :not_current, -> { where.not(year: DatetimeService.current_year, term: DatetimeService.current_term) }
  scope :in_org, ->(org_code) { where(organization_code: org_code) }

  belongs_to :lecturer_identity, class_name: :UserIdentity, foreign_key: :lecturer_name, primary_key: :name
  has_many :course_book, primary_key: :ucode, foreign_key: :course_ucode
  has_many :book_data, through: :course_book
  has_many :groups

  accepts_nested_attributes_for :course_book, allow_destroy: true, limit: 10

  def self.sync_from(org, year: DatetimeService.current_year, term: DatetimeService.current_term)
    org = org.to_s.upcase
    page = 1
    begin
      # TODO: use an access token to call this request
      response = RestClient.get "#{ENV['CORE_URL']}/api/v1/organizations/#{org}/courses.json?per_page=10000&page=#{page}&fields=year,term,code,name,lecturer,general_code,department_code&filter[year]=#{year}&filter[term]=#{term}"
    rescue RestClient::Exception
    else
      Rails.logger.info "Course.sync:  - Getting courses form #{org}"
      last_page = false
      courses_inserts = []
      while last_page == false
        courses = JSON.parse(response)

        courses_inserts += courses.map { |c| "('#{org}-#{c['code']}', '#{org}', #{c['year']}, #{c['term']}, '#{c['code']}', '#{c['name'].gsub("'", "''")}', '#{c['lecturer'].gsub("'", "''")}', '#{c['general_code']}', '#{c['department_code']}')" }

        if next_match = response.headers[:link] && response.headers[:link].match(/<(?<url>[^<>]+)>; rel="next"/)
          response = RestClient.get next_match[:url]
        else
          last_page = true
        end
      end

      if courses_inserts.length > 0
        Course.where(organization_code: org, year: year, term: term).delete_all
        sql = <<-eof
          INSERT INTO courses (ucode, organization_code, year, term, code, name, lecturer_name, general_code, department_code)
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
end
