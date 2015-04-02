class CSVFormatter
  HEADER = ['Prison', 'Total', 'Waiting', 'Overdue', 'Rejected', 'Confirmed', 'End-to-end (median)', 'End-to-end (95th)', 'Rejected overall', 'Rejected (no slot)', 'Rejected (not on contact list)', 'Rejected (no VOs left)', 'NOMIS ID']

  def initialize(nomis_ids, prison_labeling_function)
    @nomis_ids = nomis_ids
    @prison_labeling_function = prison_labeling_function.bind(self)
  end

  def generate(dataset)
    CSV.generate(headers: true) do |csv|
      csv << HEADER
      @nomis_ids.each do |nomis_id|
        csv << 
          [
           @prison_labeling_function.call(nomis_id),
           dataset.total_visits[nomis_id],
           dataset.waiting_visits[nomis_id],
           dataset.overdue_visits[nomis_id],
           dataset.rejected_visits[nomis_id],
           dataset.confirmed_visits[nomis_id],
           dataset.end_to_end_median_times[nomis_id],
           dataset.end_to_end_times[nomis_id],
           dataset.percent_rejected(nomis_id),
           dataset.percent_rejected(nomis_id, Confirmation::NO_SLOT_AVAILABLE),
           dataset.percent_rejected(nomis_id, Confirmation::NOT_ON_CONTACT_LIST),
           dataset.percent_rejected(nomis_id, Confirmation::NO_VOS_LEFT),
           nomis_id
          ]
      end
    end
  end
end
