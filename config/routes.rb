PrisonVisits2::Application.routes.draw do
  resource :feedback

  resource :prisoner_details

  namespace :deferred do
    resource :visitors_details
    resource :slots
    resource :visit
    resource :confirmation
  end

  scope :controller => 'visit' do
    get "/abandon", action: :abandon
    get "/unavailable", action: :unavailable
    get "/status/:id", action: :status, as: :visit_status
    post "/webhooks/email/:auth", controller: 'webhooks', action: 'email'
  end

  scope controller: :staff do
    get "staff" => "staff#index"
    ['changes', 'guide', 'troubleshooting', 'training', 'stats', 'downloads'].each do |n|
      label = n.gsub '-', '_'
      get "staff/#{n}", action: label, as: label
    end
  end

  scope controller: :static do
    get "cookies-disabled", action: :cookies_disabled, as: :cookies_disabled
    get "cookies", action: :cookies
    get "unsubscribe", action: :unsubscribe
    get "terms-and-conditions", action: :terms_and_conditions
  end

  get "static/500"
  get "static/503"
  get "static/404"
  get "static/prison_emails"

  scope controller: :metrics do
    get "metrics", action: :index
    get "metrics/weekly", action: :weekly
    get "metrics/:prison/all_time", action: :all_time, as: :prison_metrics_all_time
    get "metrics/:prison/fortnightly", action: :fortnightly, as: :prison_metrics_fortnightly
  end

  # Legacy URLs
  get "/prisoner-details", to: redirect("/prisoner_details/edit")
  resource :confirmation, controller: 'deferred_confirmations'

  get "/", to: redirect("https://www.gov.uk/prisonvisits")
end
