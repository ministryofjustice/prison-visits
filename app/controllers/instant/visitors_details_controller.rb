class Instant::VisitorsDetailsController < ApplicationController
  include CookieGuard
  include SessionGuard
  include KillswitchGuard
  include VisitorsManipulator

  def edit
    @collect_phone_number = false
  end

  def this_path
    instant_edit_visitors_details_path
  end

  def next_path
    instant_edit_slots_path
  end

  def model_class
    Instant::Visitor
  end
end
