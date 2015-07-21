class CoursesController < ApplicationController

  def index
    if params[:q].present?
      # prepare the query
      query = params[:q]
      query.downcase!
      queries = query.split(' ')[0..4]
      queries << query if queries.count > 1

      # search through the courses
      @courses = []
      queries.each do |q|
        @courses += courses_collection.simple_search(q)
      end
    else
      @courses = []
    end
  end

  private

  def courses_collection
    Course.current.where(organization_code: current_org_code)
  end
end
