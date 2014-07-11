class ApplicationController < ActionController::Base
  def self.permit_only_from_prisons
    before_filter :reject_untrusted_ips!
  end

  def self.permit_only_from_prisons_or_with_key
    before_filter :reject_untrusted_ips_and_without_key!
  end

  def reject_untrusted_ips!
    unless Rails.configuration.permitted_ips_for_confirmations.include?(request.remote_ip)
      raise ActionController::RoutingError.new('Go away')
    end
  end

  def reject_untrusted_ips_and_without_key!
    unless Rails.configuration.metrics_auth_key == params[:key]
      reject_untrusted_ips!
    end
  end
end
