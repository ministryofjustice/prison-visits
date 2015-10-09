class WebhooksController < ApplicationController
  CONDITIONS_PIPELINE = [
    :handle_unauthorized!,
    :handle_unknown_recipient!,
    :handle_blacklisted!,
    :handle_prison_email!,
    :handle_visitor_email!
  ]

  BLACKLISTED_SENDERS = %w(postmaster sendmaster no-reply noreply)

  def email
    handle_conditions { return if performed? }
  rescue ParsedEmail::ParseError, ArgumentError
    render text: "Discarded."
  end

  private

  def handle_unauthorized!
    unless authorized?
      STATSD_CLIENT.increment('pvb.app.email.unauthorized')
      render text: "Unauthorized.", status: 403
    end
  end

  def handle_unknown_recipient!
    unless parsed_email.to.local == 'no-reply'
      STATSD_CLIENT.increment('pvb.app.email.unknown_recipient')
      render text: 'Unknown recipient'
    end
  end

  def handle_blacklisted!
    if BLACKLISTED_SENDERS.include? parsed_email.from.local.downcase
      logger.error "Blacklisted sender issue.\n #{parsed_email.inspect}"
      render text: 'Sender blacklisted'
    end
  end

  def handle_prison_email!
    if parsed_email.source == :prison
      STATSD_CLIENT.increment('pvb.app.email.autorespond_to_prison')
      PrisonMailer.autorespond(parsed_email).deliver_later
      render text: "Accepted."
    end
  rescue StandardError => e
    logger.error "PrisonMailer issue #{parsed_email.inspect}\nexception: #{e}"
    raise
  end

  def handle_visitor_email!
    if parsed_email.source == :visitor
      STATSD_CLIENT.increment('pvb.app.email.autorespon_to_visitor')
      VisitorMailer.autorespond(parsed_email).deliver_later
      render text: "Accepted."
    end
  rescue StandardError => e
    logger.error "VisitorMailer issue #{parsed_email.inspect}\nexception: #{e}"
    raise
  end

  def parsed_email
    @parsed_email ||= ParsedEmail.parse(email_params)
  end

  def email_params
    params.slice(:from, :to, :subject, :text, :charsets)
  end

  def authorized?
    pad_execution_time 0.1 do
      params.key?(:auth) &&
        params[:auth] == ENV['WEBHOOK_AUTH_KEY']
    end
  end

  def handle_conditions(&_return_if_performed)
    CONDITIONS_PIPELINE.each { |condition| send(condition) && yield }
  end
end
