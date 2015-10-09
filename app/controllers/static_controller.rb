require 'csv'

class StaticController < ApplicationController
  def prison_emails
    respond_to do |format|
      format.csv do
        csv_string = CSV.generate do |csv|
          csv << ['name', 'email']
          Prison.enabled do |prison|
            csv << [prison.name, prison.email]
          end
        end

        render text: csv_string
      end
    end
  end
end
