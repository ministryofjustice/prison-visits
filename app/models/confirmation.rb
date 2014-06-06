class Confirmation
  include ActiveModel::Model
  attr_accessor :outcome, :message
  
  validates_inclusion_of :outcome, in: %w{no_slot_available not_on_contact_list slot_0 slot_1 slot_2}

  def slot_selected?
    [0, 1, 2].include?(slot)
  end

  def slot
    outcome.starts_with?('slot') && outcome.gsub('slot_', '').to_i
  end
end
