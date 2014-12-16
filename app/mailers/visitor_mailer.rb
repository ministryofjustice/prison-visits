# -*- coding: utf-8 -*-
class VisitorMailer < ActionMailer::Base

  include MailerHelper::NoReply
  include MailerHelper::Autoresponder
  include MailerHelper::Addresses

  add_template_helper(ApplicationHelper)
  add_template_helper(VisitHelper)

  layout 'email'

  attr_reader :visit
  helper_method :visit

  default('List-Unsubscribe' => '<https://www.prisonvisits.service.gov.uk/unsubscribe>')

  def booking_confirmation_email(visit, confirmation)
    @visit = visit
    @slot = visit.slots[confirmation.slot.to_i]
    @confirmation = confirmation

    mail(from: sender, reply_to: prison_mailbox_email, to: recipient, subject: "Visit confirmed: your visit for #{Date.parse(@slot.date).strftime('%e %B %Y').gsub(/^ /,'')} has been confirmed")
  end

  def booking_rejection_email(visit, confirmation)
    @visit = visit
    @confirmation = confirmation
    
    mail(from: sender, reply_to: prison_mailbox_email, to: recipient, subject: "Visit cannot take place: your visit for #{first_date.strftime('%e %B %Y').gsub(/^ /,'')} could not be booked")
  end

  def booking_receipt_email(visit)
    @visit = visit

    mail(from: sender, reply_to: prison_mailbox_email, to: recipient, subject: "Not booked yet: we've received your visit request for #{first_date.strftime('%e %B %Y').gsub(/^ /,'')}")
  end

  def instant_confirmation_email(visit)
    @visit = visit

    mail(from: sender, reply_to: prison_mailbox_email, to: recipient, subject: "Visit confirmation for #{first_date.strftime('%e %B %Y').gsub(/^ /,'')}")
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
