require 'email_validator'

class Feedback
  include ActiveModel::Model

  attr_accessor :text
  attr_accessor :email
  attr_accessor :referrer

  validates_presence_of :text
  validates_presence_of :referrer
  validates :email, email: true, if: ->(f) { f.email.present? }
end
