class VisitController < ApplicationController
  def step1
  end

  def update_step1
    params = params.require(:prisoner).permit(:given_name, :surname, :date_of_birth, :number, :prison_name)
    visit.prisoner = Prisoner.new(params)
    redirect_to step2_path
  end

  def step2
  end

  def update_step2
    params = params.require(:visitor).permit(:given_name, :surname, :date_of_birth, :email, :phone)
    visit.visitors[0] = Visitor.new(params)
    redirect_to step3_path
  end

  def step3
  end

  def update_step3
    params = params.require(:visitor).permit(:given_name, :surname, :date_of_birth, :email, :phone)
    unless visit.visitors.size == 6
      visit.visitors << Visitor.new(params)
    end
    redirect_to step3_path
  end

  def step4
  end

  def update_step4
    params = params.require(:visit).permit(:visit_date, :visit_slot)
    visit.visit_date = params[:visit_date]
    visit.visit_slot = params[:visit_slot]
    redirect_to :step5_path
  end

  def step5
  end

  def update_step5
    redirect_to :step6_path
  end

  def step6
  end
end
