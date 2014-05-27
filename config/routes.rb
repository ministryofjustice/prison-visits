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
  end

  get "cookies" => "static#cookies"
  
  get "static/404"
  get "static/500"
  get "static/503"
end
