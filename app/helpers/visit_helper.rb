module VisitHelper
  def year_limit(index)
    index.zero? ? Visitor::USER_MIN_AGE : 0
  end

  def dob_year_range(index)
    110.years.ago.strftime('%Y').to_i..year_limit(index).years.ago.strftime('%Y').to_i
  end

  def dob_month_range
    date_range = (Date.today.beginning_of_year..Date.today.end_of_year)
    date_range.group_by { |d| d.beginning_of_month }
  end

  def dob_day_range
    dec = Date.parse('2013-12-01')
    dec.beginning_of_month..dec.end_of_month
  end
end
