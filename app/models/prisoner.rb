require 'name_validator'

class Prisoner
  include ActiveModel::Model

  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :number
  attr_accessor :prison_name
  attr_accessor :date_of_birth

  validates :first_name, presence: true, name: true
  validates :last_name, presence: true, name: true
  validates_presence_of :date_of_birth
  validates_inclusion_of :date_of_birth, in: ->(_) { 100.years.ago.beginning_of_year..Time.now }, if: ->(p) { p.date_of_birth }, message: "must be a valid date of birth"
  validates_format_of :number, with: /\A[a-z]\d{4}[a-z]{2}\z/i, message: "must be a valid prisoner number" # eg a1234aa
  validates_inclusion_of :prison_name, in: Rails.configuration.prison_data.map{|k,v|k}.sort, message: "must be chosen"

  def full_name
    [@first_name, @last_name].join(' ')
  end

  def last_initial
    @last_name.chars.first.upcase
  end

  def age
    if date_of_birth
      (Date.today - date_of_birth.to_date).to_i / 365
    end
  end
end
