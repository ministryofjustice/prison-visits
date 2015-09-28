class SlotsController < ApplicationController
  include CookieGuard
  include SessionGuard::OnEditAndUpdate
  include SlotsManipulator
  before_action :ensure_visit_integrity, only: [:edit, :update]

  def edit
    @slots = visit.slots.empty? ? [Slot.new, Slot.new, Slot.new] : visit.slots
    @schedule = PrisonSchedule.new(Prison.find(visit.prisoner.prison_name))
  end

  def max_slots
    3
  end

  def this_path
    edit_slots_path
  end

  def next_path
    edit_visit_path
  end
end
