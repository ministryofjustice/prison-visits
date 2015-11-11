class MetricsController < ApplicationController
  permit_only_trusted_users
  before_action :nomis_ids, only: [:index, :weekly]

  def index
    check_params_range

    respond_to do |format|
      format.html
      format.csv do
        render text: CSVFormatter.new(
          @nomis_ids,
          ApplicationHelper.instance_method(:prison_estate_name_for_id)
        ).generate(@dataset)
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
    @start_date, @end_date = Time.zone.today - 18, Time.zone.today - 4
    @dataset = DetailedWindowedMetrics.new(
      VisitMetricsEntry.deferred, @nomis_id, @start_date..@end_date)
    respond_to do |format|
      format.html
    end
  end

  def fortnightly_performance
    @nomis_id = prison_param
    @year = year_param

    report = FortnightlyPerformanceReport.new(
      VisitMetricsEntry, @nomis_id, @year)
    @percentile95 = report.performance(0.95)
    @percentile50 = report.performance(0.5)
    @volume = report.volume

    respond_to do |format|
      format.html
    end
  end

  def weekly
    # First monday of the year, most of the time.
    @start_of_year = start_of_year
    @dataset = dataset(@start_of_year)

    respond_to do |format|
      format.html
      format.csv do
        render text: @dataset.csv
      end
    end
  end

  def nomis_ids
    @nomis_ids = Prison.enabled_nomis_ids
  end

  def fortnightly_range
    (Time.zone.today - 18)..(Time.zone.today - 4)
  end

  def prison_param
    (prison = params[:prison]) && Prison.nomis_ids.include?(prison) && prison
  end

  def year_param
    (params[:year] || Time.now.year).to_i
  end

  private

  def check_params_range
    if params[:range] == 'all'
      @dataset = CalculatedMetrics.new(VisitMetricsEntry.deferred, 3.days)
    else
      @start_date, @end_date = fortnightly_range.first, fortnightly_range.last
      @dataset = CalculatedMetrics.new(
        VisitMetricsEntry.deferred, 3.days, fortnightly_range
      )
    end
  end

  def start_of_year
    Date.commercial(year_param)
  end

  def dataset(start_of_year)
    WeeklyConfirmationsReport.new(
      VisitMetricsEntry.deferred,
      year_param,
      start_of_year,
      ApplicationHelper.instance_method(:prison_estate_name_for_id)
    ).refresh
  end
end
