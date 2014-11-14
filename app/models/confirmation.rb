class Confirmation
  include ActiveModel::Model
  attr_accessor :outcome, :vo_number

  NO_SLOT_AVAILABLE = 'no_slot_available'
  PRISONER_INCORRECT = 'prisoner_incorrect'
  NOT_ON_CONTACT_LIST = 'not_on_contact_list'
  VISITOR_BANNED = 'visitor_banned'
  NO_VOS_LEFT = 'no_vos_left'
  NO_PVOS_LEFT = 'no_pvos_left'
  
  validates_inclusion_of :outcome, in: [NO_SLOT_AVAILABLE, PRISONER_INCORRECT, NOT_ON_CONTACT_LIST, VISITOR_BANNED, NO_VOS_LEFT, NO_PVOS_LEFT] + %w{slot_0 slot_1 slot_2}

  def slot_selected?
    [0, 1, 2].include?(slot)
  end

  def slot
    outcome.starts_with?('slot') && outcome.gsub('slot_', '').to_i
  end
end
