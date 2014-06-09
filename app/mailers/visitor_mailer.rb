require 'mailer_helper'

class VisitorMailer < ActionMailer::Base

  include MailerHelper::NoReply
  include MailerHelper::Autoresponder
  include MailerHelper::Addresses

  add_template_helper(ApplicationHelper)
  add_template_helper(VisitHelper)
  
  def booking_confirmation_email(visit, confirmation)
    @visit = visit
    @slot = visit.slots[confirmation.slot.to_i]
    @message_from_prison = confirmation.message

    mail(from: sender, reply_to: prison_mailbox_email, to: recipient, subject: "Your visit for #{Date.parse(@slot.date).strftime('%e %B %Y').gsub(/^ /,'')} has been confirmed")
  end

  def booking_rejection_email(visit, confirmation)
    @visit = visit
    @message_from_prison = confirmation.message
    @confirmation = confirmation
    
    mail(from: sender, reply_to: prison_mailbox_email, to: recipient, subject: "Your visit for #{first_date.strftime('%e %B %Y').gsub(/^ /,'')} could not be booked")
  end

  def booking_receipt_email(visit)
    @visit = visit

    mail(from: sender, reply_to: prison_mailbox_email, to: recipient, subject: "Your visit request for #{first_date.strftime('%e %B %Y').gsub(/^ /,'')} will be processed soon")
  end

  def sender
    noreply_address
  end

  def recipient
    first_visitor_email
  end

  def first_date
    Date.parse(@visit.slots.first.date)
  end
end
