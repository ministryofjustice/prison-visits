class VisitorsDetailsController < ApplicationController
  include CookieGuard
  include SessionGuard::OnEditAndUpdate
  include VisitorsManipulator
  before_action :ensure_visit_integrity, only: [:edit, :update]

  def edit
    @collect_phone_number = true
  end

  def this_path
    edit_visitors_details_path
  end

  def next_path
    edit_slots_path
  end

  def model_class
    Visitor
  end
end
