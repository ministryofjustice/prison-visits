PrisonVisits2::Application.routes.draw do
  # rubocop:disable Metrics/LineLength
  get 'ping' => 'ping#index'

  resource :feedback

  resources :frontend_events, only: [:create]

  get 'prisoner'           => 'prisoner_details#edit', as: :edit_prisoner_details
  post 'prisoner'          => 'prisoner_details#update', as: :prisoner_details

  get 'visitors'         => 'visitors_details#edit', as: :edit_visitors_details
  post 'visitors'        => 'visitors_details#update', as: :visitors_details

  get 'slots'            => 'slots#edit', as: :edit_slots
  post 'slots'           => 'slots#update', as: :slots

  get 'visit'            => 'visits#edit', as: :edit_visit
  post 'visit'           => 'visits#update', as: :visit
  get 'your-visit/:state' => 'visits#show', as: :show_visit

  get 'confirmation/new' => 'confirmations#new', as: :new_confirmation
  get 'confirmation/:visit_id'     => 'confirmations#show', as: :show_confirmation, constraints: { visit_id: /[0-9a-f]{32}/ }
  post 'confirmation'    => 'confirmations#create', as: :confirmation

  scope controller: :visit do
    get "/abandon", action: :abandon
    get "/timeout", action: :timeout
    get "/unavailable", action: :unavailable
    get "/status/:id", action: :status, as: :visit_status
    post "/status/:id", action: :update_status, as: :update_visit_status
    post "/webhooks/email/:auth", controller: 'webhooks', action: 'email'
  end

  scope controller: :staff do
    get "staff" => "staff#index"
    ['changes', 'guide', 'troubleshooting', 'training', 'stats', 'downloads', 'telephone-script'].each do |n|
      label = n.tr '-', '_'
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
    get "metrics/:prison/fortnightly_performance", action: :fortnightly_performance, as: :prison_metrics_fortnightly_performance
    get "metrics/:prison/fortnightly", action: :fortnightly, as: :prison_metrics_fortnightly
  end

  scope controller: :geckoboard do
    get "gecko/leaderboard", action: :leaderboard
    get "gecko/rag_status", action: :rag_status
    get "gecko/confirmed_bookings", action: :confirmed_bookings
  end

  get "/healthcheck.json", controller: 'healthcheck', action: 'index'

  # Legacy URLs
  get "/prisoner-details", to: redirect("/prisoner")
  get "/deferred/confirmation/new" => "confirmations#new"

  get "/", to: redirect(ENV.fetch("GOVUK_START_PAGE", "/prisoner"))
end
