class MetricsController < ApplicationController
#  permit_only_from_prisons_or_with_key

  def index
    @prisons = Rails.configuration.prison_data.keys.sort
    versioned_dataset = cache_refresher.update(cache_refresher.fetch, Time.now)
    @overdue_threshold = 3.days.ago
    @dataset = versioned_dataset.dataset

    respond_to do |format|
      format.html
      format.csv do
        render text: CSVStreamer.new(versioned_dataset, @overdue_threshold).csv
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

  def elastic_client
    ELASTIC_CLIENT
  end

  def cache_refresher
    @refresher ||= CacheRefresher.new(elastic_client, @prisons)
  end
end
