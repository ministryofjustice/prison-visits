class GeckoboardController < ApplicationController
  permit_only_from_prisons_or_with_key

  def leaderboard
    order = params[:order] == 'top' ? :top : :bottom
    render json: LeaderboardReport.new(order, 0.95, ApplicationHelper.instance_method(:prison_name_for_id))
  end

  def rag_status
    render json: RagStatusReport.new(0.95)
  end

  def confirmed_bookings
    render json: {
      item: [
             {
               value: VisitMetricsEntry.deferred.confirmed.count,
               text: "Total confirmed bookings"
             }
            ]
    }
  end
end
