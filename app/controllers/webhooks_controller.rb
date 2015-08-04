class WebhooksController < ApplicationController
  def email
    if authorized?
      p = ParsedEmail.parse(email_params)

      unless p.to.local == 'no-reply'
        STATSD_CLIENT.increment('pvb.app.email.unknown_recipient')
        render text: 'Unknown recipient'
        return
      end

      if p.from.address == 'postmaster@hmps.gsi.gov.uk'
        logger.error "Sender ( postmaster@hmps.gsi.gov.uk ) detected. Skipping message.\n #{p.inspect}"
        render text: 'Sender postmaster@hmps.gsi.gov.uk'
        return
      end

      case p.source
      when :prison
        begin
          STATSD_CLIENT.increment('pvb.app.email.autorespond_to_prison')
          PrisonMailer.autorespond(p).deliver_now
        rescue Exception => e
          logger.error "Issue with e-mail detected ( PrisonMailer ): #{p}\nexception: #{e}"
          raise
        end
      when :visitor
        begin
          STATSD_CLIENT.increment('pvb.app.email.autorespon_to_visitor')
          VisitorMailer.autorespond(p).deliver_now
        rescue Exception => e
          logger.error "Issue with e-mail detected ( VisitorMailer ): #{p}\nexception: #{e}"
          raise
        end
      end

      render text: "Accepted."
    else
      STATSD_CLIENT.increment('pvb.app.email.unauthorized')
      render text: "Unauthorized.", status: 403
    end
  rescue ParsedEmail::ParseError, ArgumentError
    render text: "Discarded."
  end

  def email_params
    params.slice(:from, :to, :subject, :text, :charsets)
  end

  def authorized?
    !params[:auth].empty? && params[:auth].secure_compare(ENV['WEBHOOK_AUTH_KEY'])
  end
end
