class Confirmation
  include ActiveModel::Model
  attr_accessor :outcome, :vo_number, :renew_vo, :renew_pvo, :banned_visitors, :unlisted_visitors

  NO_SLOT_AVAILABLE = 'no_slot_available'
  NO_ALLOWANCE = 'no_allowance'
  NO_VOS_LEFT = 'no_vos_left'
  NO_PVOS_LEFT = 'no_pvos_left'
  PRISONER_INCORRECT = 'prisoner_incorrect'
  PRISONER_NOT_PRESENT = 'prisoner_not_present'
  NOT_ON_CONTACT_LIST = 'not_on_contact_list'
  VISITOR_BANNED = 'visitor_banned'

  validate :check_outcome

  def check_outcome
    outcomes = [
      NO_SLOT_AVAILABLE,
      NO_ALLOWANCE,
      NO_VOS_LEFT,
      NO_PVOS_LEFT,
      PRISONER_INCORRECT,
      PRISONER_NOT_PRESENT,
      NOT_ON_CONTACT_LIST,
      VISITOR_BANNED
    ] + %w{slot_0 slot_1 slot_2}

    if !outcomes.include?(outcome)
      errors.add(:outcome, 'An outcome must be chosen')
    end
  end

  def slot_selected?
    [0, 1, 2].include?(slot)
  end

  def slot
    outcome && outcome.starts_with?('slot') && outcome.gsub('slot_', '').to_i
  end
end
