class CSVStreamer < Enumerator
  def initialize(versioned_dataset, timestamp)
    super() do |e|
      e.yield(CSV.generate_line(['Prison', 'Total', 'Waiting', 'Overdue', 'Rejected', 'Confirmed', 'End-to-end time', 'Processing time', '% rejected']))
      versioned_dataset.prisons.each do |prison|
        e.yield(CSV.generate_line(versioned_dataset[prison].as_csv_row(prison, timestamp)))
      end
    end
  end

  def csv
    to_a.join
  end
end
