class Slot
  include NonPersistedModel

  BOOKABLE_DAYS = 28

  attribute :date, String
  attribute :times, String
  attribute :slot, String
  attribute :index, Integer

  validate do
    if index == 0
      errors.add(:date, 'must be given') unless date.present? && date.size == 10
      unless times.present? && times.size == 9
        errors.add(:times, 'must be given')
      end
    end
  end

  def weekday
    Date.parse(date).strftime('%A')
  end
end
