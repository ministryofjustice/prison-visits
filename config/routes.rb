PrisonVisits2::Application.routes.draw do
  resource :feedback

  scope :controller => 'visit' do
    ['prisoner-details','visitor-details','choose-date-and-time','check-your-request','request-sent'].each do |n|
      label = n.gsub '-', '_'
      get "/#{n}", action: label, as: label
      post "/#{n}", action: "update_#{label}", as: "update_#{label}"
    end
    get "/abandon", action: :abandon
    get "/cal", action: :cal
    get "/", to: redirect("/prisoner-details")
    get "/unavailable", action: :unavailable
  end
end
