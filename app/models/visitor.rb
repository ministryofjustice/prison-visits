class Visitor
  include ActiveModel::Model

  attr_accessor :given_name
  attr_accessor :surname
  attr_accessor :date_of_birth
  attr_accessor :email
  attr_accessor :phone
end
