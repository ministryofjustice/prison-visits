class VisitController < ApplicationController
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
    @visitors = visit.visitors
  end

  def update_step2
    visit.visitors = visit_params.map do |visitor_hash|
      Visitor.new(visitor_hash)
    end
    go_back = visit.visitors.select do |v|
      !v.valid?
    end.any?

    if params[:next] == 'add'
      visit.visitors << Visitor.new
      redirect_to step2_path
    else
      redirect_to go_back ? step2_path : step4_path
    end
  end

  def step3
    @index = visit.visitors.size
  end

  def update_step3
    visit.visitors[params[:index].to_i] = Visitor.new(visitor_params[0])
    redirect_to params[:next] == 'add' ? step3_path : step4_path
  end

  def step4
    @slots = visit.slots.empty? ? [Slot.new, Slot.new, Slot.new] : visit.slots
  end

  def update_step4
    visit.slots = []
    slot_params.each do |p|
      visit.slots << Slot.new(p)
    end
    redirect_to step5_path
  end

  def step5
  end

  def update_step5
    BookingRequest.request_email(visit).deliver
    redirect_to step6_path
  end

  after_filter :reset_session, only: :step6

  def step6
  end

private

  def visit_params
    params.require(:visit).require(:visitor)
  end

  def prisoner_params
    params.require(:prisoner).permit(:full_name, :date_of_birth, :number, :prison_name, :visiting_order)
  end

  # def visitor_params
  #   params.require(:visitors).permit(:full_name, :date_of_birth, :email, :phone)
  # end

  def slot_params
    params.require(:visit).require(:slots)
  end
end
