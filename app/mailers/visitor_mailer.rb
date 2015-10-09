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
        slot_date: Date.parse(@slot.date).strftime('%e %B %Y').gsub(/^ /,'')
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
        first_date: first_date.strftime('%e %B %Y').gsub(/^ /,'')
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
        first_date: first_date.strftime('%e %B %Y').gsub(/^ /,'')
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
    Date.parse(@visit.slots.first.date)
  end

  def receipt_date
    first_date.strftime('%e %B %Y').gsub(/^ /,'')
  end

  alias_method :rejection_date, :receipt_date

  def confirmation_date
    Date.parse(@slot.date).strftime('%e %B %Y').gsub(/^ /,'')
  end
end
