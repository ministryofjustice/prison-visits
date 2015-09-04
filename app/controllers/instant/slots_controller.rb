class Instant::SlotsController < ApplicationController
  include CookieGuard
  include SessionGuard
  include KillswitchGuard
  include SlotsManipulator
  before_action :ensure_visit_integrity, only: [:edit, :update]

  def edit
    @slots = visit.slots.empty? ? [Slot.new] : visit.slots
    @schedule = PrisonSchedule.new(Prison.find(visit.prisoner.prison_name))
  end

  def max_slots
    1
  end

  def this_path
    instant_edit_slots_path
  end

  def next_path
    instant_edit_visit_path
  end
end
