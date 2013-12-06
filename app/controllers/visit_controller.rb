require 'google_analytics_adapter'

class VisitController < ApplicationController
  before_filter :check_if_within_business_hours, except: [:unavailable]
  before_filter :check_if_session_exists, except: [:prisoner_details, :unavailable]

  def check_if_session_exists
    unless session[:visit]
      redirect_to(prisoner_details_path)
      return
    end
  end

  def check_if_within_business_hours
    if !(7..22).include?(Time.now.hour)
      redirect_to(unavailable_path)
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

    if params[:next] == 'Add another visitor'
      if visit.visitors.size < Visit::MAX_VISITORS
        visit.visitors << Visitor.new
        redirect_to visitor_details_path
      else
        redirect_to visitor_details_path, notice: "You may only have a maximum of #{Visit::MAX_VISITORS} visitors"
      end
    else
      redirect_to go_back ? visitor_details_path : choose_date_and_time_path
    end
  end

  def choose_date_and_time
    @slots = visit.slots.empty? ? [Slot.new, Slot.new, Slot.new] : visit.slots
  end

  def update_choose_date_and_time
    visit.slots = []
    slot_params.each_with_index do |slot_hash, i|
      visit.slots << Slot.new(slot_hash_from_string(slot_hash[:slot]).merge(index: i))
    end
    
    go_back = visit.slots.select do |slot|
      !slot.valid?
    end.any? || visit.slots.size > Visit::MAX_SLOTS

    if go_back
      redirect_to choose_date_and_time_path
    else
      redirect_to check_your_request_path
    end
  end

  def check_your_request
  end

  def update_check_your_request
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
    params[:visit][:visitor].each do |visitor|
      date_of_birth = [:'date_of_birth(3i)', :'date_of_birth(2i)', :'date_of_birth(1i)'].map do |key|
        visitor.delete(key)
      end.join('-')
      begin
        visitor[:date_of_birth] = Date.parse(date_of_birth)
      rescue ArgumentError
        # NOOP
      end
    end
    params.require(:visit).require(:visitor)
  end

  def prisoner_params
    date_of_birth = [:'date_of_birth(3i)', :'date_of_birth(2i)', :'date_of_birth(1i)'].map do |key|
      params[:prisoner].delete(key)
    end.join('-')
    params[:prisoner][:date_of_birth] = Date.parse(date_of_birth)
    params.require(:prisoner).permit(:first_name, :last_name, :date_of_birth, :number, :prison_name)
  rescue ArgumentError
    params.require(:prisoner).permit(:first_name, :last_name, :number, :prison_name)
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
