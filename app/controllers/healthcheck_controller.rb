class HealthcheckController < ApplicationController
  permit_only_trusted_users

  def index
    healthcheck = Healthcheck.new
    status = healthcheck.ok? ? nil : :bad_gateway
    render status: status, json: healthcheck.checks
  end
end
