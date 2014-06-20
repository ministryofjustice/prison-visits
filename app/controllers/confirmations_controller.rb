class ConfirmationsController < ApplicationController
  helper_method :booked_visit
  permit_only_from_prisons

  def new
    reset_session if params[:state]
    @confirmation = Confirmation.new
    metrics_logger.record_link_click(booked_visit)
    if metrics_logger.processed?(booked_visit)
      reset_session
      render '_already_booked'
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    render '_bad_state', status: 400
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
    session[:booked_visit] ||= legacy_data_fixes(encryptor.decrypt_and_verify(params[:state]))
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

  def legacy_data_fixes(visit)
    if prison_name = {
        'Liverpool' => 'Liverpool (Open only)',
        'Winchester' => 'Winchester (Convicted only)',
        'Bullingdon' => 'Bullingdon (Convicted Only)'
      }[visit.prisoner.prison_name]
      visit.prisoner.prison_name = prison_name
    end
    visit
  end
end
