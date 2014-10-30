class PrisonerDetailsController < ApplicationController
  before_filter :check_if_cookies_enabled, only: :update
  helper_method :visit

  def edit
  end

  def update
    if (visit.prisoner = Prisoner.new(prisoner_params)).valid?
      render text: 'OK'
    else
      redirect_to edit_prisoner_details_path
    end
  end

  def check_if_cookies_enabled
    unless cookies['cookies-enabled']
      redirect_to cookies_disabled_path
      return
    end
  end

  def visit
    Visit.new(prisoner: Prisoner.new)
  end

  def prisoner_params
    dob = [:'date_of_birth(3i)', :'date_of_birth(2i)', :'date_of_birth(1i)']
    if params[:date_of_birth_native].present?
      params[:prisoner][:date_of_birth] = Date.parse(params[:date_of_birth_native])
      dob.map{|d| params[:prisoner].delete(d)}
    else
      date_of_birth = dob.map do |key|
        params[:prisoner].delete(key).to_i
      end
      params[:prisoner][:date_of_birth] = Date.new(*date_of_birth.reverse)
    end
    ParamUtils.trim_whitespace_from_values(params.require(:prisoner).permit(:first_name, :last_name, :date_of_birth, :number, :prison_name))
  rescue ArgumentError
    ParamUtils.trim_whitespace_from_values(params.require(:prisoner).permit(:first_name, :last_name, :number, :prison_name))
  end
end
