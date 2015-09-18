class WebhooksController < ApplicationController
  def email
    if authorized?
      p = ParsedEmail.parse(email_params)

      unless p.to.local == 'no-reply'
        STATSD_CLIENT.increment('pvb.app.email.unknown_recipient')
        render text: 'Unknown recipient'
        return
      end

      blacklist = %w(postmaster sendmaster no-reply noreply)

      if blacklist.include? p.from.local.downcase
        logger.error "Blacklisted sender detected. Skipping message.\n #{p.inspect}"
        render text: 'Sender blacklisted'
        return
      end

      case p.source
      when :prison
        begin
          STATSD_CLIENT.increment('pvb.app.email.autorespond_to_prison')
          PrisonMailer.autorespond(p).deliver_later
        rescue StandardError => e
          logger.error "Issue with e-mail detected ( PrisonMailer ): #{p.inspect}\nexception: #{e}"
          raise
        end
      when :visitor
        begin
          STATSD_CLIENT.increment('pvb.app.email.autorespon_to_visitor')
          VisitorMailer.autorespond(p).deliver_later
        rescue StandardError => e
          logger.error "Issue with e-mail detected ( VisitorMailer ): #{p.inspect}\nexception: #{e}"
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
