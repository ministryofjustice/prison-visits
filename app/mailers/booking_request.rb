class BookingRequest < ActionMailer::Base
  add_template_helper(ApplicationHelper)

  EMAILS = {
    'Rochester' => 'socialvisits.rochester@hmps.gsi.gov.uk',
    'Durham' => 'socialvisits.durham@hmps.gsi.gov.uk'
  }

  def request_email(visit)
    @visit = visit
    user = visit.visitors.find { |v| v.email }.email

    recipient = if production?
      EMAILS[visit.prisoner.prison_name]
    else
      'pvb-email-test@googlegroups.com'
    end

    mail(from: 'prisonvisitsbooking@digital.justice.gov.uk', to: recipient, subject: 'Visit request', reply_to: user)
  end

  def production?
    ENV['APP_PLATFORM'] == 'production'
  end
end
