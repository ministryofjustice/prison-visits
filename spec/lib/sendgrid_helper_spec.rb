require 'rails_helper'
require 'sendgrid_helper'

RSpec.describe SendgridHelper do
  subject { described_class }

  context 'with sendgrid configured' do
    around do |example|
      smtp_settings = Rails.configuration.action_mailer.smtp_settings
      Rails.configuration.action_mailer.smtp_settings = {
        user_name: 'test_smtp_username',
        password: 'test_smtp_password'
      }
      example.run
      Rails.configuration.action_mailer.smtp_settings = smtp_settings
    end

    context 'spam reports' do
      let(:body) { '[]' }

      before do
        stub_request(:get,'https://sendgrid.com/api/spamreports.get.json').
          with(query: hash_including({
                'api_key'   => 'test_smtp_password',
                'api_user'  => 'test_smtp_username',
                'email'     => 'test@example.com'})
          ).to_return(status: 200, body: body, headers: {})
      end

      context 'error handling' do
        context 'when the API raises an exception' do
          before do
            allow(Curl::Easy).to receive(:perform).and_raise(Curl::Err::CurlError)
          end

          it 'has no spam report' do
            expect(subject.spam_reported?('test@example.com')).to be_falsey
          end
        end

        context 'when the API reports an error' do
          let(:body) { '{"error":"LOL"}' }

          it 'has no spam report' do
            expect(subject.spam_reported?('test@example.com')).to be_falsey
          end
        end
      end

      context 'when no error' do
        context 'when there is no spam report' do
          let(:body) { '[]' }

          it 'has no spam report' do
            expect(subject.spam_reported?('test@example.com')).to be_falsey
          end
        end

        context 'when there is a spam report' do
          let(:body) {
            %<[
              {
                "ip": "174.36.80.219",
                "email": "test@example.com",
                "created": "2009-12-06 15:45:08"
              }
            ]>
          }

          it 'has a spam report' do
            expect(subject.spam_reported?('test@example.com')).to be_truthy
          end
        end
      end
    end

    context 'bounced' do
      let(:body) { '[]' }

      before do
        stub_request(:get,'https://sendgrid.com/api/bounces.get.json').
          with(query: hash_including({
                'api_key'   => 'test_smtp_password',
                'api_user'  => 'test_smtp_username',
                'email'     => 'test@example.com'})
          ).to_return(status: 200, body: body, headers: {})
      end

      context 'error handling' do
        context 'when the API raises an exception' do
          before do
            allow(Curl::Easy).to receive(:perform).and_raise(Curl::Err::CurlError)
          end

          it 'has no bounce' do
            expect(subject.bounced?('test@example.com')).to be_falsey
          end
        end

        context 'when the API reports an error' do
          let(:body) { '{"error":"LOL"}' }

          it 'has no bounce' do
            expect(subject.bounced?('test@example.com')).to be_falsey
          end
        end
      end

      context 'when no error' do
        context 'when there is no bounce' do
          let(:body) { '[]' }

          it 'has no bounce' do
            expect(subject.bounced?('test@example.com')).to be_falsey
          end
        end

        context 'when there is a bounce' do
          let(:body) {
            %<[
              {
                "status": "4.0.0",
                "created": "2011-09-16 22:02:19",
                "reason": "Unable to resolve MX host example.com",
                "email": "test@example.com"
              }
            ]>
          }

          it 'has a bounce' do
            expect(subject.bounced?('test@example.com')).to be_truthy
          end
        end
      end
    end
  end

  context 'without sendgrid configured' do
    around do |example|
      smtp_settings = Rails.configuration.action_mailer.smtp_settings
      Rails.configuration.action_mailer.smtp_settings = {}
      example.run
      Rails.configuration.action_mailer.smtp_settings = smtp_settings
    end

    context 'bounced?' do
      it 'never says that the email has bounced' do
        expect(subject.bounced?('test@example.com')).to be_falsey
      end

      it 'does not talk to sendgrid' do
        expect(Curl::Easy).to receive(:perform).never
        subject.bounced?('test@example.com')
      end
    end

    context 'spam_reported?' do
      it 'never says that the email address has been reported for spam' do
        expect(subject.spam_reported?('test@example.com')).to be_falsey
      end

      it 'does not talk to sendgrid' do
        expect(Curl::Easy).to receive(:perform).never
        subject.spam_reported?('test@example.com')
      end
    end
  end

  context 'sendgrid connection test' do
    let :host do
      'smtp.sendgrid.net'
    end

    let :port do
      587
    end

    context 'when it connects' do
      it 'will return true' do
        expect(Net::SMTP).to receive(:start)
        expect(subject.smtp_alive?(host, port)).to be_truthy
      end
    end

    context 'when it times out' do
      it 'will return false' do
        expect(Net::SMTP).to receive(:start).and_raise(Net::OpenTimeout)
        expect(subject.smtp_alive?(host, port)).to be_falsey
      end
    end

    context 'when the port is closed' do
      it 'will return false' do
        expect(Net::SMTP).to receive(:start).and_raise(Errno::ECONNREFUSED)
        expect(subject.smtp_alive?(host, port)).to be_falsey
      end
    end

    context 'when the hostname cannot be resolved' do
      it 'will return false' do
        expect(Net::SMTP).to receive(:start).and_raise(SocketError)
        expect(subject.smtp_alive?(host, port)).to be_falsey
      end
    end
  end
end
