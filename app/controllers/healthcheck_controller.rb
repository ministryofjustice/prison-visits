class HealthcheckController < ApplicationController
  permit_only_with_key

  def index
    checks = {
      sendgrid: sendgrid_alive?,
      messagelabs: messagelabs_alive?,
      database: database_active?,
      zendesk: zendesk_alive?
    }
    status = :bad_gateway unless checks.values.all?
    render status: status, json: { checks: checks }
  end

  private

  def sendgrid_alive?
    SendgridApi.smtp_alive?(*VisitorMailer.smtp_settings.values_at(:address, :port))
  end

  def messagelabs_alive?
    SendgridApi.smtp_alive?(*PrisonMailer.smtp_settings.values_at(:address, :port))
  end

  def database_active?
    ActiveRecord::Base.connection.active?
  rescue PG::ConnectionBad
    false
  end

  def zendesk_alive?
    ZENDESK_CLIENT.tickets.count >= 0
  end
end
