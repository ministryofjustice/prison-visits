require 'zendesk_helper'

class FeedbacksController < ApplicationController
  def index
  end

  def new
    @feedback ||= Feedback.new
  end

  def create
    @feedback = Feedback.new(feedback_params)
    if @feedback.valid?
      ZendeskHelper.send_to_zendesk(@feedback)
      redirect_to feedback_path
    else
      render 'new'
    end
  end

  private
  def feedback_params
    params.require(:feedback).permit(:referrer, :text, :email)
  end
end
