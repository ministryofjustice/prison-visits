class HeartbeatController < ApplicationController
  permit_only_with_key

  def healthcheck
    checks = {
      sendgrid: sendgrid_alive?,
      messagelabs: messagelabs_alive?,
      database: ActiveRecord::Base.connection.active?,
    }
    status = :bad_gateway unless checks.values.all?
    render status: status, json: {
      checks: checks
    }
  end

  def sendgrid_alive?
    SendgridHelper.smtp_alive?(*VisitorMailer.smtp_settings.values_at(:address, :port))
  end

  def messagelabs_alive?
    SendgridHelper.smtp_alive?(*PrisonMailer.smtp_settings.values_at(:address, :port))
  end
end
