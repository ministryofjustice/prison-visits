PrisonVisits2::Application.routes.draw do
  resource :feedback

  get 'prisoner'           => 'prisoner_details#edit', as: :edit_prisoner_details
  post 'prisoner'          => 'prisoner_details#update', as: :prisoner_details

  namespace :deferred do
    get 'visitors'         => 'visitors_details#edit', as: :edit_visitors_details
    post 'visitors'        => 'visitors_details#update', as: :visitors_details

    get 'slots'            => 'slots#edit', as: :edit_slots
    post 'slots'           => 'slots#update', as: :slots

    get 'visit'            => 'visits#edit', as: :edit_visit
    post 'visit'           => 'visits#update', as: :visit
    get 'your-visit'       => 'visits#show', as: :show_visit

    get 'confirmation/new' => 'confirmations#new', as: :new_confirmation
    get 'confirmation'     => 'confirmations#show', as: :show_confirmation
    post 'confirmation'    => 'confirmations#create', as: :confirmation
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
  
  scope controller: :prisons do
    get "prisons/", action: :index
    get "prisons/:prison", action: :show
  end

  scope controller: :metrics do
    get "metrics", action: :index
    get "metrics/weekly", action: :weekly
    get "metrics/:prison/all_time", action: :all_time, as: :prison_metrics_all_time
    get "metrics/:prison/fortnightly", action: :fortnightly, as: :prison_metrics_fortnightly
  end

  # Legacy URLs
  get "/prisoner-details", to: redirect("/prisoner")
  resource :confirmation, controller: 'deferred/confirmations'

  get "/", to: redirect("https://www.gov.uk/prisonvisits")
end
