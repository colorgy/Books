class LecturerBooks::LecturerSelectionsController < ApplicationController
  layout 'blank'

  def index
    if params[:q].blank? || params[:org].blank?
      @lecturers = Course.current.where('organization_code = ?', params[:org]).limit(100).order('RANDOM()').select(:lecturer_name, :organization_code).map(&:lecturer_name).uniq.map { |n| { value: n, label: n } }
      render json: @lecturers
    else
      @lecturers = Course.current.where('organization_code = ? AND lecturer_name LIKE ?', params[:org], "%#{params[:q]}%").select(:lecturer_name, :organization_code).map(&:lecturer_name).uniq.map { |n| { value: n, label: n } }
      render json: @lecturers
    end
  end
end
