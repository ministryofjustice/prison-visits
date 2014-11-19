class MetricsController < ApplicationController
  permit_only_from_prisons_or_with_key

  def index
    @prisons = Rails.configuration.prison_data.keys.sort
    if params[:range] == 'all'
      @dataset = CalculatedMetrics.new(VisitMetricsEntry.deferred, 3.days)
    else
      @start_date, @end_date = fortnightly_range.first, fortnightly_range.last
      @dataset = CalculatedMetrics.new(VisitMetricsEntry.deferred, 3.days, fortnightly_range)
    end

    respond_to do |format|
      format.html
      format.csv do
        render text: CSVFormatter.new(@prisons).generate(@dataset)
      end
    end
  end

  def all_time
    @prison = params[:prison]
    @dataset = DetailedMetrics.new(VisitMetricsEntry.deferred, @prison)
    respond_to do |format|
      format.html
    end
  end

  def fortnightly
    @prison = params[:prison]
    @start_date, @end_date = Date.today - 18, Date.today - 4
    @dataset = DetailedWindowedMetrics.new(VisitMetricsEntry.deferred, @prison, @start_date..@end_date)
    respond_to do |format|
      format.html
    end
  end

  def weekly
    year = (params[:year] || Time.now.year).to_i
    # First monday of the year, most of the time.
    @start_of_year = Date.new(year, 1, 1) - Date.new(year, 1, 1).wday + 1
    @dataset = WeeklyConfirmationsReport.new(VisitMetricsEntry.deferred, year, @start_of_year).refresh
    @prisons = Rails.configuration.prison_data.keys.sort

    respond_to do |format|
      format.html
      format.csv do
        render text: @dataset.csv
      end
    end
  end

  def fortnightly_range
    (Date.today - 18)..(Date.today - 4)
  end
end
