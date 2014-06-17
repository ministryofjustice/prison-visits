class BookingConfirmation < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  include MailerHelper::NoReply

  def confirmation_email(visit)
    @visit = visit
    recipient = visit.visitors.find { |v| v.email }.email

    prison_mailbox = Rails.configuration.prison_data[visit.prisoner.prison_name]['email']

    first_date = Date.parse(@visit.slots.first.date)
    mail(from: noreply_address, reply_to: prison_mailbox, to: recipient, subject: "You have requested a visit for #{first_date.strftime('%e %B %Y').gsub(/^ /,'')}")
  end
end
