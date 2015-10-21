# -*- coding: utf-8 -*-
class VisitorMailer < ActionMailer::Base
  include NoReply
  include Autoresponder
  include Addresses
  include EnsureQuotedPrintable
  include DateHelper

  add_template_helper(DateHelper)
  add_template_helper(ApplicationHelper)
  add_template_helper(VisitHelper)

  layout 'email'

  attr_reader :visit
  helper_method :visit

  default('List-Unsubscribe' => Rails.configuration.unsubscribe_url)

  def booking_confirmation_email(visit, confirmation, token)
    @visit = visit
    @slot = visit.slots[confirmation.slot.to_i]
    @confirmation = confirmation
    @token = token

    mail(
      from: sender,
      reply_to: prison_mailbox_email,
      to: recipient,
      subject: default_i18n_subject(
        confirmation_date: format_date_of_visit(slot_date)
      )
    )
  end

  def booking_rejection_email(visit, confirmation)
    @visit = visit
    @confirmation = confirmation

    mail(
      from: sender,
      reply_to: prison_mailbox_email,
      to: recipient,
      subject: default_i18n_subject(
        rejection_date: format_date_of_visit(first_date)
      )
    )
  end

  def booking_receipt_email(visit, token)
    @visit = visit
    @token = token

    SpamAndBounceResets.new(@visit.visitors.first).perform_resets

    mail(
      from: sender,
      reply_to: prison_mailbox_email,
      to: recipient,
      subject: default_i18n_subject(
        receipt_date: format_date_of_visit(first_date)
      )
    )
  end

  def sender
    noreply_address
  end

  def recipient
    first_visitor_email
  end

  def first_date
    @visit.slots.first.date
  end

  def slot_date
    @slot.date
  end
end
