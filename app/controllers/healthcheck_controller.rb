class HealthcheckController < ApplicationController
  permit_only_from_prisons_or_with_key

  def index
    healthcheck = Healthcheck.new
    status = healthcheck.ok? ? nil : :bad_gateway
    render status: status, json: healthcheck.checks
  end
end
