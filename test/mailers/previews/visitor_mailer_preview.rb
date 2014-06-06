class VisitorMailerPreview < ActionMailer::Preview
  include MailerPreviewCommon

  def booking_confirmation
    VisitorMailer.booking_confirmation_email(sample_visit, accepted_confirmation)
  end

  def booking_rejection_rejected_no_slots
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation('no_slot_available'))
  end

  def booking_rejection_not_on_contact_list
    VisitorMailer.booking_rejection_email(sample_visit, rejected_confirmation('not_on_contact_list'))
  end

  def booking_receipt
    VisitorMailer.booking_receipt_email(sample_visit)
  end
end
