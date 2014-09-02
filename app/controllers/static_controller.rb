require 'csv'

class StaticController < ApplicationController
  def prison_emails
    respond_to do |format|
      format.csv do
        csv_string = CSV.generate do |csv|
          csv << ['name', 'email']
          Rails.configuration.prison_data.each_pair do |prison_name, data|
            csv << [prison_name, data[:email]] if data[:enabled]
          end
        end

        render text: csv_string
      end
    end
  end
end
