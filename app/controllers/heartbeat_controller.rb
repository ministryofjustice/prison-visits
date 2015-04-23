class HeartbeatController < ApplicationController
  permit_only_with_key

  def healthcheck
    render json: {
      checks: {
        sendgrid: sendgrid_alive?,
        messagelabs: messagelabs_alive?,
        database: ActiveRecord::Base.connection.active?
      }
    }
  end

  def sendgrid_alive?
    SendgridHelper.smtp_alive?(*VisitorMailer.smtp_settings.values_at(:address, :port))
  end

  def messagelabs_alive?
    SendgridHelper.smtp_alive?(*PrisonMailer.smtp_settings.values_at(:address, :port))
  end
end
