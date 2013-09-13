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
  end

  def update_step2
    if (visit.visitors[params[:index].to_i] = Visitor.new(visitor_params)).valid?
      redirect_to params[:next] == 'add' ? step3_path : step4_path
    else
      redirect_to step2_path
    end
  end

  def step3
    @index = visit.visitors.size
  end

  def update_step3
    visit.visitors[params[:index].to_i] = Visitor.new(visitor_params)
    redirect_to params[:next] == 'add' ? step3_path : step4_path
  end

  def step4
  end

  def update_step4
    visit.slots = []
    params.require(:visit).permit(:"slots[]").each do |date, slot|
      visit.slots << Slot.new(date, slot)
    end
    redirect_to :step5_path
  end

  def step5
  end

  def update_step5
    redirect_to :step6_path
  end

  def step6
  end

private

  def prisoner_params
    params.required(:prisoner).permit(:first_name, :last_name, :date_of_birth, :number, :prison_name)
  end

  def visitor_params
    params.required(:visitor).permit(:first_name, :last_name, :date_of_birth, :email, :phone)
  end
end
