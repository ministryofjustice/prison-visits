class Deferred::SlotsController < ApplicationController
  include CookieGuard
  include SessionGuard
  include SlotsManipulator

  def edit
    @slots = visit.slots.empty? ? [Slot.new, Slot.new, Slot.new] : visit.slots
    @schedule = PrisonSchedule.new(Prison.find(visit.prisoner.prison_name))
  end

  def max_slots
    3
  end

  def this_path
    deferred_edit_slots_path
  end

  def next_path
    deferred_edit_visit_path
  end
end
