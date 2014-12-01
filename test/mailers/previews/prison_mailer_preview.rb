class PrisonMailerPreview < ActionMailer::Preview
  include MailerPreviewCommon

  def booking_request
    PrisonMailer.booking_request_email(sample_visit, SecureRandom.hex * 40)
  end

  def booking_receipt_accepted
    PrisonMailer.booking_receipt_email(sample_visit, accepted_confirmation)
  end

  def booking_confirmation_visitors_unlisted
    PrisonMailer.booking_receipt_email(sample_visit, accepted_confirmation_visitors_unlisted)
  end

  def booking_confirmation_banned_visitors
    PrisonMailer.booking_receipt_email(sample_visit, accepted_confirmation_visitor_banned)
  end

  def booking_confirmation_banned_and_unlisted_visitors
    PrisonMailer.booking_receipt_email(sample_visit, accepted_confirmation_visitor_banned_and_unlisted)
  end

  def booking_receipt_rejected_no_slots
    PrisonMailer.booking_receipt_email(sample_visit, rejected_confirmation('no_slot_available'))
  end

  def booking_receipt_rejected_not_on_contact_list
    PrisonMailer.booking_receipt_email(sample_visit, rejected_confirmation(Confirmation::NOT_ON_CONTACT_LIST))
  end

  def booking_receipt_rejected_no_vos_left
    PrisonMailer.booking_receipt_email(sample_visit, rejected_confirmation(Confirmation::NO_VOS_LEFT))
  end

  def booking_receipt_rejected_prisoner_incorrect
    PrisonMailer.booking_receipt_email(sample_visit, rejected_confirmation(Confirmation::PRISONER_INCORRECT))
  end

  def booking_receipt_rejected_prisoner_not_present
    PrisonMailer.booking_receipt_email(sample_visit, rejected_confirmation(Confirmation::PRISONER_NOT_PRESENT))
  end
end
