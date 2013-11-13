PrisonVisits2::Application.routes.draw do
  scope :controller => 'visit' do
    (1..6).each do |n|
      label = "step#{n}"
      get "/#{n}", action: label, as: label
      post "/#{n}", action: "update_#{label}", as: "update_#{label}"
    end
    get "/abandon", action: :abandon
    get "/", to: redirect("/1")
  end
end
