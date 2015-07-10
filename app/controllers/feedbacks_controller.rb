class FeedbacksController < ApplicationController

  def create
    if current_user
      @feedback = current_user.feedbacks.build(feedback_params)
    else
      @feedback = Feedback.new(feedback_params)
    end

    respond_to do |format|
      if @feedback.save
        format.json { render json: @feedback }
      else
        format.json { render json: @feedback.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:subject, :content, :sent_by, :sent_at)
  end
end
