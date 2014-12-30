class Confirmation
  include ActiveModel::Model
  attr_accessor :outcome, :message, :vo_number, :no_vo, :no_pvo, :renew_vo, :renew_pvo, :banned_visitors, :unlisted_visitors, :visitor_not_listed, :visitor_banned, :canned_response, :closed_visit

  NO_VOS_LEFT = 'no_vos_left'
  NO_SLOT_AVAILABLE = 'no_slot_available'
  NO_ALLOWANCE = 'no_allowance'
  PRISONER_INCORRECT = 'prisoner_incorrect'
  PRISONER_NOT_PRESENT = 'prisoner_not_present'
  NOT_ON_CONTACT_LIST = 'not_on_contact_list'
  SLOTS_RESPONSES = %w{slot_0 slot_1 slot_2}

  validate :check_outcome
  validate :reference
  validate :renewals
  validate :unlisted
  validate :banned

  def check_outcome
    outcomes = [
      NO_VOS_LEFT,
      NO_SLOT_AVAILABLE,
      NO_ALLOWANCE,
      PRISONER_INCORRECT,
      PRISONER_NOT_PRESENT,
      NOT_ON_CONTACT_LIST,
    ] + SLOTS_RESPONSES

    if !outcomes.include?(outcome) && !visitor_not_listed && !visitor_banned
      errors.add(:outcome, 'an outcome must be chosen')
    end
  end

  def reference
    if SLOTS_RESPONSES.include?(outcome) && vo_number.blank? && canned_response
      errors.add(:vo_number, 'you must supply a reference number')
    end
  end

  def renewals
    if outcome == NO_ALLOWANCE
      if no_vo.present? && renew_vo.nil?
        errors.add(:no_vo, 'a renewal date must be chosen')
      end
      if no_pvo.present? && renew_pvo.nil?
        errors.add(:no_pvo, 'a renewal date must be chosen')
      end
    end
  end

  def banned
    if visitor_banned && banned_visitors.nil?
      errors.add(:banned, 'one or more visitors must be selected')
    end
  end

  def unlisted
    if visitor_not_listed && unlisted_visitors.nil?
      errors.add(:unlisted, 'one or more visitors must be selected')
    end
  end

  def slot_selected?
    [0, 1, 2].include?(slot)
  end

  def slot
    outcome && outcome.starts_with?('slot') && outcome.gsub('slot_', '').to_i
  end
end
