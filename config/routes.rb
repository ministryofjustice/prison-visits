PrisonVisits2::Application.routes.draw do
  resource :feedback
  resource :confirmation

  scope :controller => 'visit' do
    ['prisoner-details','visitor-details','choose-date-and-time','check-your-request','request-sent'].each do |n|
      label = n.gsub '-', '_'
      get "/#{n}", action: label, as: label
      post "/#{n}", action: "update_#{label}", as: "update_#{label}"
    end
    get "/abandon", action: :abandon
    get "/", to: redirect("/prisoner-details")
    get "/unavailable", action: :unavailable
    get "/status/:id", action: :status, as: :visit_status
    post "/webhooks/email/:auth", controller: 'webhooks', action: 'email'
  end

  scope :controller => 'staff' do
    get "staff" => "staff#index"
    ['changes', 'guide', 'troubleshooting', 'training', 'stats', 'downloads'].each do |n|
      label = n.gsub '-', '_'
      get "staff/#{n}", action: label, as: label
    end
  end

  get "cookies-disabled" => "static#cookies_disabled", as: :cookies_disabled
  get "cookies" => "static#cookies"
  get "unsubscribe" => "static#unsubscribe"
  get "terms-and-conditions" => "static#terms_and_conditions"

  get "static/500"
  get "static/503"
  get "static/404"

  get "metrics/weekly" => "metrics#weekly"
  get "metrics(/:prison)(.:format)" => "metrics#index"
end
