class VisitController < ApplicationController
  before_filter :check_if_session_exists, except: [:step1]

  def check_if_session_exists
    unless session[:visit]
      redirect_to(step1_path)
      return
    end
  end

  def step1
  end

  def update_step1
    if (visit.prisoner = Prisoner.new(prisoner_params)).valid?
      redirect_to step2_path
    else
      redirect_to step1_path
    end
  end

  def step2
  end

  def update_step2
    if m = params[:next].match(/remove-(\d)/)
      index = m[1].to_i
      visit.visitors.delete_at(index)
      redirect_to step2_path
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
        redirect_to step2_path
      else
        redirect_to step2_path, notice: "You may only have a maximum of #{Visit::MAX_VISITORS} visitors"
      end
    else
      redirect_to go_back ? step2_path : step4_path
    end
  end

  def step4
    @slots = visit.slots.empty? ? [Slot.new, Slot.new, Slot.new] : visit.slots
  end

  def update_step4
    visit.slots = []
    slot_params.each_with_index do |slot_hash, i|
      visit.slots << Slot.new(slot_hash_from_string(slot_hash[:slot]).merge(index: i))
    end
    
    go_back = visit.slots.select do |slot|
      !slot.valid?
    end.any? || visit.slots.size > Visit::MAX_SLOTS

    if go_back
      redirect_to step4_path
    else
      redirect_to step5_path
    end
  end

  def step5
  end

  def update_step5
    BookingRequest.request_email(visit).deliver
    redirect_to step6_path
  end

  def step6
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

  # def visitor_params
  #   params.require(:visitors).permit(:first_name, :last_name, :date_of_birth, :email, :phone)
  # end

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
