class HealthcheckController < ApplicationController
  permit_only_with_key

  def index
    healthcheck = Healthcheck.new
    status = healthcheck.ok? ? nil : :bad_gateway
    render status: status,
      json: {
        checks: healthcheck.checks,
        queues: healthcheck.queues
      }
  end
end
