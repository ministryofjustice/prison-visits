require 'visit_state_encryptor'

class ConfirmationsController < ApplicationController
  def new
  end

  def create
    if params[:confirmation][:slot] == 'none'
      VisitorMailer.booking_rejected_email(booked_visit)
    else
      VisitorMailer.booking_confirmed_email(booked_visit)
    end
    PrisonMailer.booking_receipt_email(booked_visit)
    redirect_to confirmation_path
  end

  def booked_visit
    session[:booked_visit] ||= encryptor.decrypt(params[:state])
  end

  def encryptor
    VisitStateEncryptor.new("LOL" * 48)
  end
end
