class Confirmation
  include ActiveModel::Model
  attr_accessor :outcome, :message

  NO_SLOT_AVAILABLE = 'no_slot_available'
  NOT_ON_CONTACT_LIST = 'not_on_contact_list'
  NO_VOS_LEFT = 'no_vos_left'
  
  validates_inclusion_of :outcome, in: [NO_SLOT_AVAILABLE, NOT_ON_CONTACT_LIST, NO_VOS_LEFT] + %w{slot_0 slot_1 slot_2}

  def slot_selected?
    [0, 1, 2].include?(slot)
  end

  def slot
    outcome.starts_with?('slot') && outcome.gsub('slot_', '').to_i
  end
end
