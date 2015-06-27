module DatetimeService
  class << self
    def current_year
      (Time.now.month >= 6) ? Time.now.year : Time.now.year - 1
    end

    def current_term
      (Time.now.month >= 6) ? 1 : 2
    end

    def current_batch
      batch(year: current_year, term: current_term)
    end

    def batch(year: nil, term: nil)
      year ||= current_year
      term ||= current_term
      "#{year}-#{term}"
    end
  end
end
