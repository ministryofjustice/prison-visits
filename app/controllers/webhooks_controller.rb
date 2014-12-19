class WebhooksController < ApplicationController
  def email
    if authorized?
      p = ParsedEmail.parse(email_params)
      
      unless p.to.local == 'no-reply'
        STATSD_CLIENT.increment('pvb.app.email.unknown_recipient')
        render text: 'Unknown recipient'
        return
      end
      
      case p.source
      when :prison
        STATSD_CLIENT.increment('pvb.app.email.autorespond_to_prison')
        PrisonMailer.autorespond(p).deliver
      when :visitor
        STATSD_CLIENT.increment('pvb.app.email.autorespon_to_visitor')
        VisitorMailer.autorespond(p).deliver
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
