class Deferred::VisitorsDetailsController < ApplicationController
  include CookieGuard
  include SessionGuard
  include VisitorsManipulator

  def edit
    @collect_phone_number = true
    render 'shared/visitors_details/edit'
  end

  def this_path
    deferred_edit_visitors_details_path
  end

  def next_path
    deferred_edit_slots_path
  end

  def model_class
    Deferred::Visitor
  end
end
