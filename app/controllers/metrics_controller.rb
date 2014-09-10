class MetricsController < ApplicationController
  permit_only_from_prisons_or_with_key

  def index
    @prisons = Rails.configuration.prison_data.keys.sort
    @dataset = CalculatedMetrics.new(VisitMetricsEntry, 3.days).refresh

    respond_to do |format|
      format.html
      format.csv do
        render text: CSVFormatter.new(@prisons).generate(@dataset)
      end
    end
  end

  def weekly
    @report = WeeklyConfirmationsReport.from_elasticsearch(elastic_client.search(index: :pvb, q: "label0:result_*", size: 1_000_000))
    @prisons = @report.prisons
    @this_week_no = Time.now.yday / 7

    respond_to do |format|
      format.html
      format.csv do
        render text: @report.csv
      end
    end
  end
end
