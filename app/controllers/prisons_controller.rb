class PrisonsController < ApplicationController
  helper_method :visit

  def show
    @data = Rails.configuration.prison_data[params['prison'].titleize]    
  end  
end
