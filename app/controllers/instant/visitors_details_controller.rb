class Instant::VisitorsDetailsController < ApplicationController
  def edit
    @collect_phone_number = false
    render 'shared/visitors_details/edit'
  end
end
