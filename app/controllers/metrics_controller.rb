class MetricsController < ApplicationController
  permit_only_from_prisons_or_with_key

  def index
    @nomis_ids = Rails.configuration.nomis_ids
    if params[:range] == 'all'
      @dataset = CalculatedMetrics.new(VisitMetricsEntry.deferred, 3.days)
    else
      @start_date, @end_date = fortnightly_range.first, fortnightly_range.last
      @dataset = CalculatedMetrics.new(VisitMetricsEntry.deferred, 3.days, fortnightly_range)
    end

    respond_to do |format|
      format.html
      format.csv do
        render text: CSVFormatter.new(@nomis_ids, ApplicationHelper.instance_method(:prison_name_for_id)).generate(@dataset)
      end
    end
  end

  def all_time
    @nomis_id = prison_param
    @dataset = DetailedMetrics.new(VisitMetricsEntry.deferred, @nomis_id)
    respond_to do |format|
      format.html
    end
  end

  def fortnightly
    @nomis_id = prison_param
    @start_date, @end_date = Date.today - 18, Date.today - 4
    @dataset = DetailedWindowedMetrics.new(VisitMetricsEntry.deferred, @nomis_id, @start_date..@end_date)
    respond_to do |format|
      format.html
    end
  end

  def fortnightly_performance
    @nomis_id = prison_param
    @year = year_param

    report = FortnightlyPerformanceReport.new(VisitMetricsEntry, @nomis_id, @year)
    @percentile95 = report.performance(0.95)
    @percentile50 = report.performance(0.5)
    @volume = report.volume

    respond_to do |format|
      format.html
    end
  end

  def weekly
    year = year_param
    # First monday of the year, most of the time.
    @start_of_year = Date.new(year, 1, 1) - Date.new(year, 1, 1).wday + 1
    @dataset = WeeklyConfirmationsReport.new(VisitMetricsEntry.deferred, year, @start_of_year, ApplicationHelper.instance_method(:prison_name_for_id)).refresh
    @nomis_ids = Rails.configuration.nomis_ids

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

  def prison_param
    (prison = params[:prison]) && Rails.configuration.nomis_ids.include?(prison) && prison
  end

  def year_param
    (params[:year] || Time.now.year).to_i
  end
end
