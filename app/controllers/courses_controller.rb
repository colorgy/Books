class CoursesController < ApplicationController

  def index
    if params[:q].present?
      @courses = Course.search(params[:q], organization_code: current_org_code, year: Course.current_year, term: Course.current_term)
    else
      @courses = []
    end
  end
end
