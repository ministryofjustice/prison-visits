class Visit
  include ActiveModel::Model

  attr_accessor :prisoner
  attr_accessor :visitors
  attr_accessor :slots

  validates_size_of :visitors, within: 1..6
end
