class StartPageController < ApplicationController
  NEW_APP_PROBABILITY_DEFAULT = 0.1

  # Used to redirect a (controllable) portion of requests to the new
  # prison-visits application, which is proxied at /en/
  def show
    # The probability that any given user will be redirected to the new app
    new_app_probability = NEW_APP_PROBABILITY_DEFAULT

    # Store a random number between 0 and 1 in the session so that the choice
    # of which app a user is directed to is fixed with respect to the value of
    # new_app_probability
    threshold = request.session[:app_choice_threshold] ||= rand

    if threshold < new_app_probability
      redirect_to '/en/request'
    else
      redirect_to '/prisoner'
    end
  end
end
