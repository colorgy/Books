module BatchCodeService
  class << self
    def current_year
      (Time.now.month > 6) ? Time.now.year : Time.now.year - 1
    end

    def current_term
      (Time.now.month > 6) ? 1 : 2
    end

    def current_batch
      "#{BatchCodeService.current_year}-#{BatchCodeService.current_term}-#{Settings.order_batch}"
    end

    def generate_group_code(organization_code, course_id, book_id, batch: nil)
      batch ||= BatchCodeService.current_batch
      "#{batch}-#{organization_code}-#{course_id}-#{book_id}"
    end
  end
end
