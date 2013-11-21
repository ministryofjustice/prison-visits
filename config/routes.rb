PrisonVisits2::Application.routes.draw do
  scope :controller => 'visit' do
    ['prisoner-details','visitor-details','visit-details','summary','request-sent'].each do |n|
      label = n.gsub '-', '_'
      get "/#{n}", action: label, as: label
      post "/#{n}", action: "update_#{label}", as: "update_#{label}"
    end
    get "/abandon", action: :abandon
    get "/", to: redirect("/prisoner-details")
  end
end
