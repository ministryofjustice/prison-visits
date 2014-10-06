class CSVFormatter
  HEADER = ['Prison', 'Total', 'Waiting', 'Overdue', 'Rejected', 'Confirmed', 'End-to-end time', 'Processing time', '% rejected']

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
           dataset.end_to_end_times[prison],
           dataset.processing_times[prison],
           dataset.total_visits[prison] > 0 ? dataset.rejected_visits[prison] / dataset.total_visits[prison] : 0
          ]
      end
    end
  end
end
