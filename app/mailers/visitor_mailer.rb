require 'mailer_helper'

class VisitorMailer < ActionMailer::Base
  include MailerHelper::NoReply
  include MailerHelper::Autoresponder
end
