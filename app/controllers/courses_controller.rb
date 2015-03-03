class CoursesController < ApplicationController

  def index
    if params[:q].present?
      @courses = Course.search(params[:q], organization_code: current_org_code, year: BatchCodeService.current_year, term: BatchCodeService.current_term)
    else
      @courses = []
    end
  end
end
