class LecturerBooks::OrganizationSelectionsController < ApplicationController
  layout 'blank'

  def index
    @org_selections = Organization.all.map do |org|
      { value: org.code, label: "#{org.name} (#{org.code})" }
    end

    render json: @org_selections
  end
end
