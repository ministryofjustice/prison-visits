class WebhooksController < ApplicationController
  def email
    if authorized?
      p = ParsedEmail.parse(email_params)
      
      unless p.to.local == 'no-reply'
        render text: 'Unknown recipient'
        return
      end
      
      case p.source
      when :prison
        PrisonMailer.autorespond(p).deliver
      when :visitor
        VisitorMailer.autorespond(p).deliver
      end
      
      render text: "Accepted."
    else
      render text: "Unauthorized.", status: 403
    end
  rescue ParsedEmail::ParseError, ArgumentError
    render text: "Discarded."
  end

  def email_params
    params.slice(:from, :to, :subject, :text, :charsets)
  end

  def authorized?
    !params[:auth].empty? && params[:auth] == ENV['WEBHOOK_AUTH_KEY']
  end
end
