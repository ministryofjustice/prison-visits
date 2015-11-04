class CSVFormatter
  HEADER = [
    'Prison', 'Total', 'Waiting', 'Overdue', 'Rejected', 'Confirmed',
    'End-to-end (median)', 'End-to-end (95th)', 'Rejected overall',
    'Rejected (no slot)', 'Rejected (not on contact list)',
    'Rejected (no VOs left)', 'NOMIS ID'
  ]

  def initialize(nomis_ids, prison_labeling_function)
    @nomis_ids = nomis_ids
    @prison_labeling_function = prison_labeling_function.bind(self)
  end

  # rubocop:disable Metrics/MethodLength
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
            dataset.percent_rejected(nomis_id, no_slot_available),
            dataset.percent_rejected(nomis_id, not_on_contact_list),
            dataset.percent_rejected(nomis_id, no_vos_left),
            nomis_id
          ]
      end
    end
  end

  private

  def no_slot_available
    Confirmation::NO_SLOT_AVAILABLE
  end

  def not_on_contact_list
    Confirmation::NOT_ON_CONTACT_LIST
  end

  def no_vos_left
    Confirmation::NO_VOS_LEFT
  end
end
