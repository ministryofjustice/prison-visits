class Slot
  include ActiveModel::Model

  LEAD_DAYS = 3
  BOOKABLE_DAYS = 28
  UNBOOKABLE_DATES = {
    rochester: ['2013-12-25','2013-12-26'],
    cardiff: [],
    durham: [],
    gartree: []
  }
  TIMES = {
    rochester: {
      mon: [['1400','1600']],
      tue: [['1400','1600']],
      wed: [['1400','1600']],
      thu: [['1400','1600']],
      sat: [['0915','1115'], ['1400','1600']],
      sun: [['1400','1600']]
    },
    cardiff: {
      mon: [['1350','1450'],['1450','1600']],
      tue: [['1350','1450'],['1450','1600']],
      wed: [['1350','1450'],['1450','1600']],
      thu: [['1350','1450'],['1450','1600']],
      fri: [['1350','1450'],['1450','1600']],
      sat: [['0945','1115'],['1350','1520']],
      sun: [['1350','1520']]
    },
    durham: {
      mon: [['1345','1545']],
      tue: [['1345','1545'],['1715','1900']],
      wed: [['1345','1545'],['1715','1900']],
      thu: [['1345','1545']],
      fri: [['1345','1545']],
      sat: [['0900','1145'],['1345','1645']],
      sun: [['0900','1145'],['1345','1645']]
    },
    gartree: {
      tue: [['1400','1600']],
      thu: [['1400','1600']],
      sat: [['0915','1115']],
      sun: [['1400','1600']]
    }
  }

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
