class Feedback
  include ActiveModel::Model

  attr_accessor :text
  attr_accessor :email
  attr_accessor :referrer

  validates_presence_of :text
  validates_presence_of :email
  validates_presence_of :referrer
end
