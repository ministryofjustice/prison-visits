class ConfirmationsController < ApplicationController
  helper_method :booked_visit
  permit_only_from_prisons

  def new
    reset_session if params[:state]
    @confirmation = Confirmation.new
    metrics_logger.record_link_click(booked_visit)

    if metrics_logger.processed?(booked_visit)
      reset_session
      STATSD_CLIENT.increment('pvb.app.already_booked')
      render '_already_booked'
    end

    if metrics_logger.request_cancelled?(booked_visit)
      reset_session
      render '_request_cancelled'
    end

    logstasher_add_visit_id(booked_visit.visit_id)
  end

  def create
    logstasher_add_visit_id(booked_visit.visit_id)
    unless set_confirmation_params
      return render :new
    end

    if @confirmation.slot_selected?
      token = encryptor.encrypt_and_sign(
        attach_vo_number(
          remove_unused_slots(
            booked_visit, @confirmation.slot),
          @confirmation)
      )

      VisitorMailer.booking_confirmation_email(
        booked_visit,
        @confirmation,
        token
      ).deliver_later

      STATSD_CLIENT.increment("pvb.app.visit_confirmed")
      metrics_logger.record_booking_confirmation(booked_visit)
    else
      VisitorMailer.booking_rejection_email(
        booked_visit, @confirmation
      ).deliver_later

      STATSD_CLIENT.increment("pvb.app.visit_rejected")
      metrics_logger.record_booking_rejection(
        booked_visit,
        @confirmation.outcome
      )
    end
    PrisonMailer.booking_receipt_email(booked_visit, @confirmation).
      deliver_later

    STATSD_CLIENT.increment("pvb.app.visit_processed")
    redirect_to show_confirmation_path(visit_id: booked_visit.visit_id)
  end

  def show
    logstasher_add_visit_id(params[:visit_id])
    reset_session
  end

  def booked_visit
    @booked_visit ||=
      legacy_data_fixes(encryptor.decrypt_and_verify(params[:state]))
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
      :canned_response, banned_visitors: [], unlisted_visitors: [])
  end

  LEGACY_PRISON_NAMES = {
    'Hollesley Bay'                     => 'Hollesley Bay Open',
    'Hatfield (moorland Open)'          => 'Hatfield Open',
    'Highpoint'                         => 'Highpoint North',
    'Albany'                            => 'Isle of Wight - Albany',
    'Parkhurst'                         => 'Isle of Wight - Parkhurst',
    'Liverpool (Open only)'             => 'Liverpool Social Visits',
    'Hindley (Young Adult 18-21 only)'  => 'Hindley',
    'Hindley (Young People 15-18 only)' => 'Hindley'
  }

  def legacy_data_fixes(visit)
    if LEGACY_PRISON_NAMES.key?(visit.prison_name)
      STATSD_CLIENT.increment('pvb.app.legacy_data_fixes')
      visit.prison_name = LEGACY_PRISON_NAMES[visit.prison_name]
    end
    visit
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
end
