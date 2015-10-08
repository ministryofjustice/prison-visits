class FeedbacksController < ApplicationController

  def index
  end

  def new
    @feedback ||= Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)
    @feedback.prison = prison_name if visit

    if @feedback.valid?
      FeedbackMailer.new_feedback(@feedback).deliver_later
      ZendeskTicketsJob.perform_later(@feedback) unless @feedback.email.empty?
      redirect_to feedback_path
    else
      render 'new'
    end
  end

  private

  def feedback_params
    params.
      require(:feedback).
      permit(:referrer, :text, :email, :user_agent, :prison).
      merge(user_agent: request.headers['HTTP_USER_AGENT'])
  end
end
