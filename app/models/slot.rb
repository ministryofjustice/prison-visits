class Slot
  include ActiveModel::Model

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
      mon: [['1345','1445'],['1500','1600']],
      tue: [['1345','1445'],['1500','1600']],
      wed: [['1345','1445'],['1500','1600']],
      thu: [['1345','1445'],['1500','1600']],
      fri: [['1345','1445'],['1500','1600']],
      sat: [['0945','1115'], ['1350','1520']],
      sun: [['1350','1520']]
    },
    durham: {
      mon: [['1345','1545']],
      tue: [['1345','1545']],
      wed: [['1345','1545']],
      thu: [['0930','1130'],['1345','1545']],
      fri: [['0930','1130'],['1345','1545']],
      sat: [['0930','1130'],['1345','1545']],
      sun: [['0930','1130'],['1345','1545']]
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

end
