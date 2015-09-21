# -*- coding: utf-8 -*-
class VisitorMailer < ActionMailer::Base
  include NoReply
  include Autoresponder
  include Addresses
  include EnsureQuotedPrintable

  add_template_helper(ApplicationHelper)
  add_template_helper(VisitHelper)

  layout 'email'

  attr_reader :visit
  helper_method :visit

  default('List-Unsubscribe' => '<https://www.prisonvisits.service.gov.uk/unsubscribe>')

  def booking_confirmation_email(visit, confirmation, token)
    @visit = visit
    @slot = visit.slots[confirmation.slot.to_i]
    @confirmation = confirmation
    @token = token

    mail(from: sender,
         reply_to: prison_mailbox_email,
         to: recipient,
         subject: "Visit confirmed: your visit for #{confirmation_date} has been confirmed")
  end

  def booking_rejection_email(visit, confirmation)
    @visit = visit
    @confirmation = confirmation

    mail(from: sender,
         reply_to: prison_mailbox_email,
         to: recipient,
         subject: "Visit cannot take place: your visit for #{rejection_date} could not be booked")
  end

  def booking_receipt_email(visit, token)
    @visit = visit
    @token = token

    perform_sendgrid_resets

    mail(from: sender,
         reply_to: prison_mailbox_email,
         to: recipient,
         subject: "Not booked yet: we've received your visit request for #{receipt_date}")
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

  def receipt_date
    first_date.strftime('%e %B %Y').gsub(/^ /,'')
  end

  alias_method :rejection_date, :receipt_date

  def confirmation_date
    Date.parse(@slot.date).strftime('%e %B %Y').gsub(/^ /,'')
  end

  def first_visitor
    @visit.visitors.first
  end

  delegate :email, :reset_bounce?, :reset_spam_report?,
    :override_email_checks?, to: :first_visitor

  delegate :remove_from_bounce_list, :remove_from_spam_list,
    to: :SendgridApi

  def perform_sendgrid_resets
    return unless override_email_checks?
    remove_from_bounce_list(email) if reset_bounce?
    remove_from_spam_list(email) if reset_spam_report?
  end
end
