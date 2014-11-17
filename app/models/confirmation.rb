class Confirmation
  include ActiveModel::Model
  attr_accessor :outcome, :vo_number, :renew_vo, :renew_pvo, :not_on_contact_list, :visitor_banned

  NO_SLOT_AVAILABLE = 'no_slot_available'
  NO_ALLOWANCE = 'no_allowance'
  NO_VOS_LEFT = 'no_vos_left'
  NO_PVOS_LEFT = 'no_pvos_left'
  PRISONER_INCORRECT = 'prisoner_incorrect'
  NOT_ON_CONTACT_LIST = 'not_on_contact_list'
  VISITOR_BANNED = 'visitor_banned'

  validate :check_outcome

  def check_outcome
    outcomes = [
      NO_SLOT_AVAILABLE,
      NO_VOS_LEFT,
      NO_PVOS_LEFT,
      NO_ALLOWANCE
    ] + %w{slot_0 slot_1 slot_2}

    if !outcomes.include?(outcome) && !not_on_contact_list && !visitor_banned
      errors.add(:outcome, 'An outcome must be chosen')
      errors.add(:not_on_contact_list, 'An outcome must be chosen')
      errors.add(:visitor_banned, 'An outcome must be chosen')
    end
  end

  def slot_selected?
    [0, 1, 2].include?(slot)
  end

  def slot
    outcome && outcome.starts_with?('slot') && outcome.gsub('slot_', '').to_i
  end
end
