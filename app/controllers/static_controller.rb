require 'csv'

class StaticController < ApplicationController
  def prison_emails
    respond_to do |format|
      format.csv do
        csv_string = csv_generator
        render text: csv_string
      end
    end
  end

  def csv_generator
    CSV.generate do |csv|
      csv << ['name', 'email']
      Prison.enabled.each do |prison|
        csv << [prison.name, prison.email]
      end
    end
  end
end
