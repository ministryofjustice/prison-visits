class ConfirmationsController < ApplicationController
  helper_method :booked_visit
  before_filter :check_ip_ranges

  def check_ip_ranges
    unless Rails.configuration.permitted_ips_for_confirmations.include?(request.remote_ip)
      raise ActionController::RoutingError.new('Not found')
    end
  end

  def new
    @confirmation = Confirmation.new
    metrics_logger.record_link_click(booked_visit)
    if metrics_logger.processed?(booked_visit)
      reset_session
      redirect_to confirmation_path
    else
      redirect_to new_confirmation_path if params[:state]
    end
  end

  def create
    unless (@confirmation = Confirmation.new(confirmation_params)).valid?
      render :new
      return
    end

    if @confirmation.slot_selected?
      VisitorMailer.booking_confirmation_email(booked_visit, @confirmation).deliver
      metrics_logger.record_booking_confirmation(booked_visit)
    else
      VisitorMailer.booking_rejection_email(booked_visit, @confirmation).deliver
      metrics_logger.record_booking_rejection(booked_visit, @confirmation.outcome)
    end
    PrisonMailer.booking_receipt_email(booked_visit, @confirmation).deliver
    redirect_to confirmation_path
    reset_session
  end

  def show
  end

  def booked_visit
    session[:booked_visit] ||= encryptor.decrypt_and_verify(params[:state])
  end

  def confirmation_params
    params.require(:confirmation).permit(:outcome, :message)
  end
  
  def encryptor
    MESSAGE_ENCRYPTOR
  end

  def metrics_logger
    METRICS_LOGGER
  end
end
