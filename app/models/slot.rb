class Slot
  include ActiveModel::Model

  BOOKABLE_DAYS = 28

  attr_accessor :date
  attr_accessor :times
  attr_accessor :slot
  attr_accessor :index

  validate do
    if index == 0
      errors.add(:date, 'must be given') unless date.present? && date.size == 10
      errors.add(:times, 'must be given') unless times.present? && times.size == 9
    end
  end

  def weekday
    Date.parse(date).strftime('%A')
  end
end
