class Confirmation
  include NonPersistedModel

  attribute :outcome, String
  attribute :message, String
  attribute :vo_number, String
  attribute :no_vo, Boolean
  attribute :no_pvo, Boolean
  attribute :renew_vo, String
  attribute :renew_pvo, String
  attribute :banned_visitors, Array[String]
  attribute :unlisted_visitors, Array[String]
  attribute :visitor_not_listed, Boolean
  attribute :visitor_banned, Boolean
  attribute :canned_response, Boolean
  attribute :closed_visit, Boolean

  NO_VOS_LEFT = 'no_vos_left'
  NO_SLOT_AVAILABLE = 'no_slot_available'
  NO_ALLOWANCE = 'no_allowance'
  PRISONER_INCORRECT = 'prisoner_incorrect'
  PRISONER_NOT_PRESENT = 'prisoner_not_present'
  NOT_ON_CONTACT_LIST = 'not_on_contact_list'
  SLOTS_RESPONSES = %w{slot_0 slot_1 slot_2}

  validate :validate_outcome
  validate :validate_reference
  validate :validate_renewals
  validate :validate_unlisted_visitors
  validate :validate_banned_visitors

  def slot_selected?
    [0, 1, 2].include?(slot)
  end

  def slot
    outcome && outcome.starts_with?('slot') && outcome.gsub('slot_', '').to_i
  end

private

  def unknown_outcome?
    outcomes = [
      NO_VOS_LEFT,
      NO_SLOT_AVAILABLE,
      NO_ALLOWANCE,
      PRISONER_INCORRECT,
      PRISONER_NOT_PRESENT,
      NOT_ON_CONTACT_LIST
    ] + SLOTS_RESPONSES
    !outcomes.include?(outcome)
  end

  def validate_outcome
    if unknown_outcome? && !visitor_not_listed && !visitor_banned
      errors.add(:outcome, 'an outcome must be chosen')
    end
  end

  def validate_reference
    if SLOTS_RESPONSES.include?(outcome) && vo_number.blank? && canned_response
      errors.add(:vo_number, 'you must supply a reference number')
    end
  end

  def validate_renewals
    if outcome == NO_ALLOWANCE
      if no_vo.present? && renew_vo.blank?
        errors.add(:no_vo, 'a renewal date must be chosen')
      end
      if no_pvo.present? && renew_pvo.blank?
        errors.add(:no_pvo, 'a renewal date must be chosen')
      end
    end
  end

  def validate_banned_visitors
    if visitor_banned && banned_visitors.blank?
      errors.add(:banned, 'one or more visitors must be selected')
    end
  end

  def validate_unlisted_visitors
    if visitor_not_listed && unlisted_visitors.blank?
      errors.add(:unlisted, 'one or more visitors must be selected')
    end
  end
end
