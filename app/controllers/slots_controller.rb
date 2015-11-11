class SlotsController < ApplicationController
  include CookieGuard
  include SessionGuard::OnEditAndUpdate

  before_action :ensure_visit_integrity, only: [:edit, :update]
  before_action :logstasher_add_visit_id_from_session

  def edit
    @slots = visit.slots.empty? ? [Slot.new, Slot.new, Slot.new] : visit.slots
    @schedule = PrisonSchedule.new(visit.prison)
  end

  def max_slots
    3
  end

  # rubocop:disable Metrics/MethodLength
  def update
    visit.slots = []
    slot_params.each_with_index do |slot_hash, i|
      visit.slots << Slot.new(slot_hash_from_string(slot_hash[:slot]).
        merge(index: i))
    end

    go_back = visit.slots.select do |slot|
      !slot.valid?
    end.any? || visit.slots.size > max_slots

    go_back = !visit.valid?(:date_and_time) || go_back

    if go_back
      redirect_to edit_slots_path
    else
      redirect_to edit_visit_path
    end
  end

  private

  def slot_params
    params.require(:visit).require(:slots)
  end

  def slot_hash_from_string(str)
    # From 2013-11-02-0945-1115
    # To { date: '2013-11-02', times: '0945-1115' }
    segments = str.split('-')
    if segments.length.zero?
      { date: '', times: '' }
    else
      {
        date: segments[0..2].join('-'),
        times: segments[3..4].join('-')
      }
    end
  end
end
