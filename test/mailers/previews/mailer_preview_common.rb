module MailerPreviewCommon
  def sample_visit
    Visit.new.tap do |v|
      v.visit_id = "ABC"
      v.slots = [Slot.new(date: '2013-07-07', times: '1400-1600'),
                 Slot.new(date: '2013-07-09', times: '1200-1400'),
                 Slot.new(date: '2013-07-11', times: '1200-1400'),]
      v.prisoner = Prisoner.new.tap do |p|
        p.date_of_birth = Date.new(2013, 6, 30)
        p.number = 'a1234bc'
        p.first_name = 'John'
        p.last_name = 'Smith'
        p.prison_name = 'Rochester'
      end
      v.visitors = [
        Visitor.new(email: 'visitor@example.com', date_of_birth: Date.new(1918, 11, 11), first_name: 'Mark', last_name: 'Jones'),
        Visitor.new(date_of_birth: Date.new(1992, 1, 1), first_name: 'Maggie', last_name: 'Jones'),
        Visitor.new(date_of_birth: Date.new(1974, 2, 2), first_name: 'Richard', last_name: 'Jones'),
        Visitor.new(date_of_birth: Date.new(2000, 3, 3), first_name: 'Emma', last_name: 'Jones')
      ]
    end
  end

  def accepted_confirmation
    Confirmation.new(outcome: 'slot_2', vo_number: '5551234')
  end

  def accepted_confirmation_visitors_unlisted
    Confirmation.new(outcome: 'slot_2', vo_number: '5551234', visitor_not_listed: true, unlisted_visitors: ['Emma;Jones'])
  end

  def accepted_confirmation_visitor_banned
    Confirmation.new(outcome: 'slot_2', vo_number: '5551234', visitor_banned: true, banned_visitors: ['Mark;Jones'])
  end

  def accepted_confirmation_visitor_banned_and_unlisted
    Confirmation.new(outcome: 'slot_2', vo_number: '5551234', visitor_not_listed: true, unlisted_visitors: ['Emma;Jones'], visitor_banned: true, banned_visitors: ['Mark;Jones'])
  end

  def rejected_confirmation(outcome)
    Confirmation.new(outcome: outcome)
  end
end

