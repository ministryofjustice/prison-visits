require 'active_support/all'

module Utilities
  extend ActiveSupport::Concern

  DAYS = {
    monday:     Date.parse('Mon 13 July 2015'),
    tuesday:    Date.parse('Tue 14 July 2015'),
    wednesday:  Date.parse('Wed 15 July 2015'),
    thursday:   Date.parse('Thu 16 July 2015'),
    friday:     Date.parse('Fri 17 July 2015'),
    saturday:   Date.parse('Sat 18 July 2015'),
    sunday:     Date.parse('Sun 19 July 2015')
  }.freeze

  WEEKDAYS = DAYS.except(:saturday, :sunday).freeze

  WEEKEND_DAYS = DAYS.slice(:saturday, :sunday).freeze

  included do
    def prison_from(prison_hash)
      Prison.new 'Example Prison', prison_hash
    end
  end
end
