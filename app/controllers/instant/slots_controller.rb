class Instant::SlotsController < ApplicationController
  include CookieGuard
  include SessionGuard
  include KillswitchGuard
  include SlotsManipulator

  def edit
    @slots = visit.slots.empty? ? [Slot.new] : visit.slots
    @schedule = Schedule.new(Rails.configuration.prison_data, Rails.configuration.bank_holidays)
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
