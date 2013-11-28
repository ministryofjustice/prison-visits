class VisitController < ApplicationController
  before_filter :check_if_session_exists, except: [:prisoner_details]

  def check_if_session_exists
    unless session[:visit]
      redirect_to(prisoner_details_path)
      return
    end
  end

  def prisoner_details
  end

  def update_prisoner_details
    if (visit.prisoner = Prisoner.new(prisoner_params)).valid?
      redirect_to visitor_details_path
    else
      redirect_to prisoner_details_path
    end
  end

  def visitor_details
  end

  def update_visitor_details
    if m = params[:next].match(/remove-(\d)/)
      index = m[1].to_i
      visit.visitors.delete_at(index)
      redirect_to visitor_details_path
      return
    end

    visit.visitors = []
    visit_params.each_with_index do |visitor_hash, i|
      visit.visitors << Visitor.new(visitor_hash.merge(index: i)) unless visitor_hash[:_destroy].present?
    end
    go_back = visit.visitors.select do |v|
      !v.valid?
    end.any?

    if params[:next] == 'add'
      if visit.visitors.size < Visit::MAX_VISITORS
        visit.visitors << Visitor.new
        redirect_to visitor_details_path
      else
        redirect_to visitor_details_path, notice: "You may only have a maximum of #{Visit::MAX_VISITORS} visitors"
      end
    else
      redirect_to go_back ? visitor_details_path : visit_details_path
    end
  end

  def visit_details
    @slots = visit.slots.empty? ? [Slot.new, Slot.new, Slot.new] : visit.slots
  end

  def update_visit_details
    visit.slots = []
    slot_params.each_with_index do |slot_hash, i|
      visit.slots << Slot.new(slot_hash_from_string(slot_hash[:slot]).merge(index: i))
    end
    
    go_back = visit.slots.select do |slot|
      !slot.valid?
    end.any? || visit.slots.size > Visit::MAX_SLOTS

    if go_back
      redirect_to visit_details_path
    else
      redirect_to summary_path
    end
  end

  def summary
  end

  def update_summary
    BookingRequest.request_email(visit).deliver
    BookingConfirmation.confirmation_email(visit).deliver
    redirect_to request_sent_path
  end

  def request_sent
    render
    reset_session
  end

  def abandon
    reset_session
  end

private

  def visit_params
    params.require(:visit).require(:visitor)
  end

  def prisoner_params
    params.require(:prisoner).permit(:first_name, :last_name, :date_of_birth, :number, :prison_name)
  end

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
