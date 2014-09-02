class StaticController < ApplicationController
  def prison_emails
    respond_to do |format|
      format.csv do
        emails = Rails.configuration.prison_data.values.select do |data|
          data[:enabled]
        end.map do |data|
          data[:email]
        end

        render text: emails.join("\n")
      end
    end
  end
end
