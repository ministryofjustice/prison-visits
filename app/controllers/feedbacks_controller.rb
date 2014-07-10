class FeedbacksController < ApplicationController
  protect_from_forgery

  def index
  end

  def new
    @feedback ||= Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)
    if visit = session[:visit]
      @feedback.prison = visit.prisoner.prison_name
    end
    if @feedback.valid?
      FeedbackMailer.new_feedback(@feedback).deliver
      ZendeskHelper.send_to_zendesk(@feedback)
      redirect_to feedback_path
    else
      render 'new'
    end
  end

  private
  def feedback_params
    params.require(:feedback).permit(:referrer, :text, :email, :user_agent, :prison)
  end
end
