class GeckoboardController < ApplicationController
  permit_only_from_prisons_or_with_key

  def leaderboard
    order = params[:order] == 'top' ? :top : :bottom
    render json: LeaderboardReport.new(order, 0.95)
  end
end
