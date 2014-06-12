class ApplicationController < ActionController::Base
  def self.permit_only_from_prisons
    before_filter :reject_untrusted_ips!
  end

  def reject_untrusted_ips!
    unless Rails.configuration.permitted_ips_for_confirmations.include?(request.remote_ip)
      raise ActionController::RoutingError.new('Go away')
    end
  end
end
