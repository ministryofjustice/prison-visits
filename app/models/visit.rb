class Visit
  include ActiveModel::Model

  attr_accessor :prisoner
  attr_accessor :visitors
  attr_accessor :visit_date
  attr_accessor :visit_slot
end
