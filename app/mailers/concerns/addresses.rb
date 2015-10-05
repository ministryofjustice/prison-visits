module Addresses
  include ActiveSupport::Concern

  def prison_mailbox_email
    Prison.find(@visit.prisoner.prison_name).email
  end

  def first_visitor_email
    visitor = @visit.visitors.find(&:email)
    Mail::Address.new.tap do |m|
      m.display_name = visitor.full_name
      m.address = visitor.email
    end.to_s
  end
end
