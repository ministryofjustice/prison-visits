class ConfirmationsController < ApplicationController
  helper_method :booked_visit
  permit_only_trusted_users

  def new
    reset_session if params[:state]
    @confirmation = Confirmation.new
    metrics_logger.record_link_click(booked_visit)

    metrics_logger_processed?(booked_visit)
    metrics_logger_request_cancelled?(booked_visit)

    logstasher_add_visit_id(booked_visit.visit_id)
  end

  def create
    logstasher_add_visit_id(booked_visit.visit_id)
    unless set_confirmation_params
      return render :new
    end

    confirmation_slot_selected?
    PrisonMailer.booking_receipt_email(booked_visit, @confirmation).
      deliver_later

    statsd_client_increment('visit_processed')
    redirect_to show_confirmation_path(visit_id: booked_visit.visit_id)
  end

  def show
    logstasher_add_visit_id(params[:visit_id])
    reset_session
  end

  def booked_visit
    @booked_visit ||= encryptor.decrypt_and_verify(params[:state])
  end

  private

  def set_confirmation_params
    params[:confirmation] && (set_new_confirmation_params).valid?
  end

  def set_new_confirmation_params
    @confirmation = Confirmation.new(confirmation_params)
  end

  def confirmation_params
    params.require(:confirmation).permit(
      :outcome, :message, :vo_number, :no_vo, :no_pvo, :renew_vo,
      :renew_pvo, :closed_visit, :visitor_not_listed, :visitor_banned,
      banned_visitors: [], unlisted_visitors: [])
  end

  def remove_unused_slots(visit, slot_index)
    visit.dup.tap do |v|
      selected_slot = visit.slots[slot_index]
      v.slots = [selected_slot]
    end
  end

  def attach_vo_number(visit, confirmation)
    visit.dup.tap { |v| v.vo_number = confirmation.vo_number }
  end

  private

  def metrics_logger_processed?(booked_visit)
    if metrics_logger.processed?(booked_visit)
      reset_session
      STATSD_CLIENT.increment('pvb.app.already_booked')
      render '_already_booked'
    end
  end

  def metrics_logger_request_cancelled?(booked_visit)
    if metrics_logger.request_cancelled?(booked_visit)
      reset_session
      render '_request_cancelled'
    end
  end

  def confirmation_slot_selected?
    if @confirmation.slot_selected?
      booking_confirmation_email
    else
      booking_rejection_email
    end
  end

  def booking_confirmation_email
    token = encryptor_encrypt_and_sign

    visitor_mailer_booking_confirmation_email(token)
    statsd_client_increment('visit_confirmed')
    metrics_logger_record_booking_confirmation
  end

  def booking_rejection_email
    visitor_mailer_booking_rejection_email
    statsd_client_increment('visit_rejected')
    metrics_logger_record_booking_rejection
  end

  def encryptor_encrypt_and_sign
    encryptor.encrypt_and_sign(
      attach_vo_number(
        remove_unused_slots(
          booked_visit, @confirmation.slot),
        @confirmation
      )
    )
  end

  def visitor_mailer_booking_confirmation_email(token)
    VisitorMailer.booking_confirmation_email(
      booked_visit,
      @confirmation,
      token
    ).deliver_later
  end

  def visitor_mailer_booking_rejection_email
    VisitorMailer.booking_rejection_email(
      booked_visit,
      @confirmation
    ).deliver_later
  end

  def metrics_logger_record_booking_confirmation
    metrics_logger.record_booking_confirmation(booked_visit)
  end

  def metrics_logger_record_booking_rejection
    metrics_logger.record_booking_rejection(
      booked_visit,
      @confirmation.outcome
    )
  end

  def statsd_client_increment(visit = '')
    STATSD_CLIENT.increment("pvb.app.#{visit}")
  end
end
