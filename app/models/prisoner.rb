class Prisoner
  include ActiveModel::Model

  attr_accessor :given_name
  attr_accessor :surname
  attr_accessor :date_of_birth
  attr_accessor :number
  attr_accessor :prison_name
end
