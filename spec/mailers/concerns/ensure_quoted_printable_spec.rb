require 'rails_helper'

# rubocop:disable RSpec/DescribedClass
RSpec.describe EnsureQuotedPrintable do
  subject do
    Class.new(ActionMailer::Base) do
      include EnsureQuotedPrintable

      def test_mail
        mail(to: 'test@lol.com',
             from: 'test@lol.biz',
             subject: 'Cool story bro') do |format|
               format.html { '<h1>Such</h1>' }
               format.text { 'text!' }
             end
      end
    end
  end

  context 'when mixed in' do
    before { subject.test_mail.deliver_now }

    let(:last_email) { ActionMailer::Base.deliveries.last }

    it 'adds a filter that ensures the content transfer encoding is set' do
      expect(last_email.content_transfer_encoding).to eq 'quoted-printable'
    end
  end
end
