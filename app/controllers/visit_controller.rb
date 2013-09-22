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
    @visitors = visit.visitors.empty? ? [Visitor.new, Visitor.new, Visitor.new, Visitor.new, Visitor.new, Visitor.new] : visit.visitors
  end

  def update_step2
    visit.visitors = []
    visit_params.each do |visitor|
      visit.visitors << Visitor.new(visitor)
    end
    # visitor_params.each do |visitor|
    #   visit.visitors << Visitor.new(visitor)
    # end
    
    # if (visit.visitor[0] = Visitor.new(visitor_params)).valid?
    #   redirect_to params[:next] == 'add' ? step3_path : step4_path
    # else
    #   redirect_to step2_path
    # end

    redirect_to params[:next] == 'add' ? step3_path : step4_path
  end

  def step3
    @index = visit.visitors.size
  end

  def update_step3
    visit.visitors[params[:index].to_i] = Visitor.new(visitor_params[0])
    redirect_to params[:next] == 'add' ? step3_path : step4_path
  end

  def step4
    visit.slots = []
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
    redirect_to :step6_path
  end

  def step6
  end

private

  def visit_params
    params.require(:visit).require(:visitor)# [:full_name, :date_of_birth, :email, :phone])
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
