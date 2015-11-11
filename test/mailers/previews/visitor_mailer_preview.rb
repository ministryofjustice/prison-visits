class VisitorMailerPreview < ActionMailer::Preview
  include MailerPreviewCommon

  def booking_confirmation
    VisitorMailer.booking_confirmation_email(sample_visit, accepted_confirmation, token)
  end

  def booking_confirmation_canned_response
    VisitorMailer.booking_confirmation_email(sample_visit, accepted_confirmation_canned_response, token)
  end

  def booking_confirmation_canned_response_remand
    VisitorMailer.booking_confirmation_email(sample_visit, accepted_confirmation_canned_response_remand)
  end

  def booking_confirmation_visitors_unlisted
    VisitorMailer.booking_confirmation_email(sample_visit, accepted_confirmation_visitors_unlisted)
  end

  def booking_confirmation_banned_visitors
    VisitorMailer.booking_confirmation_email(sample_visit, accepted_confirmation_visitor_banned)
  end

  def booking_confirmation_banned_and_unlisted_visitors
    VisitorMailer.booking_confirmation_email(sample_visit, accepted_confirmation_visitor_banned_and_unlisted, token)
  end

  def booking_confirmation_closed_visit
    VisitorMailer.booking_confirmation_email(sample_visit, accepted_confirmation_closed_visit, token)
  end

  def booking_rejection_rejected_no_slots
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation('no_slot_available'))
  end

  def booking_rejection_no_allowance
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation(Confirmation::NO_ALLOWANCE))
  end

  def booking_rejection_no_allowance_no_vo
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation_no_vo(Confirmation::NO_ALLOWANCE))
  end

  def booking_rejection_no_allowance_no_pvo
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation_no_pvo(Confirmation::NO_ALLOWANCE))
  end

  def booking_rejection_not_on_contact_list
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation(Confirmation::NOT_ON_CONTACT_LIST))
  end

  def booking_rejection_no_vos_left
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation(Confirmation::NO_VOS_LEFT))
  end

  def booking_rejection_prisoner_incorrect
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation(Confirmation::PRISONER_INCORRECT))
  end

  def booking_rejection_prisoner_not_present
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation(Confirmation::PRISONER_NOT_PRESENT))
  end

  def booking_rejection_visitor_not_listed
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation_visitor_not_listed)
  end

  def booking_rejection_visitor_banned
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation_visitor_banned)
  end

  def booking_receipt
    VisitorMailer.booking_receipt_email(sample_visit, encryptor.encrypt_and_sign(sample_visit))
  end
end
