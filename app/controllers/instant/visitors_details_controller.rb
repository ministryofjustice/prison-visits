class Instant::VisitorsDetailsController < ApplicationController
  include CookieGuard
  include SessionGuard

  def edit
    @collect_phone_number = false
    render 'shared/visitors_details/edit'
  end

  def update
    render text: 'OK'
  end
end
