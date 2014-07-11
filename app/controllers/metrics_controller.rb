class MetricsController < ApplicationController
  permit_only_from_prisons_or_with_key

  INDEX_NAME = :pvb

  def index
    @prison = clean_string(params[:prison])
    @dataset = CalculatedMetrics.from_elasticsearch(query(@prison))
    @prisons = @dataset.prisons
    
    respond_to do |format|
      format.html
      format.json { render json: @dataset }
      format.csv { render text: @dataset.csv }
    end
  end

  def weekly
    @report = WeeklyConfirmationsReport.from_elasticsearch(elastic_client.search(index: INDEX_NAME, q: "label0:result_*", size: 1_000_000))
    @prisons = @report.prisons
    @this_week_no = Time.now.yday / 7

    respond_to do |format|
      format.html
      format.csv do
        render text: @report.csv
      end
    end
  end

  def query(prison_name)
    if prison_name
      elastic_client.search(index: INDEX_NAME, q: "prison:#{prison_name}", size: 10_000, sort: 'timestamp:desc')
    else
      elastic_client.search(index: INDEX_NAME, size: 100_000, sort: 'timestamp:desc')
    end
  end
  
  def clean_string(string)
    string && string.gsub(/([-+&|!\(\){}\[\]\^\"\~\*\?\:\\])/) do |m|
      '\\' + m
    end
  end

  def elastic_client
    ELASTIC_CLIENT
  end
end
