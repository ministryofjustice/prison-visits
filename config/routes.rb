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
    post "/webhooks/email/:auth", controller: 'webhooks', action: 'email'
  end

  get "cookies" => "static#cookies"
  
  get "terms-and-conditions" => "static#terms_and_conditions"

  get "static/500"
  get "static/503"
  get "static/404"

  get "metrics/prisons(.:format)" => "metrics#prisons"
  get "metrics(/:prison)(.:format)" => "metrics#index"
end
