class GeckoboardController < ApplicationController
  permit_only_from_prisons_or_with_key

  def leaderboard
    report = LeaderboardReport.new(0.95, ApplicationHelper.instance_method(:prison_name_for_id))
    if params[:order] == 'bottom'
      render json: report.bottom(10)
    else
      render json: report.top(10)
    end
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
