class CSVFormatter
  HEADER = ['Prison', 'Total', 'Waiting', 'Overdue', 'Rejected', 'Confirmed', 'End-to-end (median)', 'End-to-end (95th)', 'Rejected overall', 'Rejected (no slot)', 'Rejected (not on contact list)', 'Rejected (no VOs left)']

  def initialize(prisons)
    @prisons = prisons
  end

  def generate(dataset)
    CSV.generate(headers: true) do |csv|
      csv << HEADER
      @prisons.each do |prison|
        csv << 
          [
           prison,
           dataset.total_visits[prison],
           dataset.waiting_visits[prison],
           dataset.overdue_visits[prison],
           dataset.rejected_visits[prison],
           dataset.confirmed_visits[prison],
           dataset.end_to_end_median_times[prison],
           dataset.end_to_end_times[prison],
           dataset.percent_rejected(prison),
           dataset.percent_rejected(prison, Confirmation::NO_SLOT_AVAILABLE),
           dataset.percent_rejected(prison, Confirmation::NOT_ON_CONTACT_LIST),
           dataset.percent_rejected(prison, Confirmation::NO_VOS_LEFT)
          ]
      end
    end
  end
end
