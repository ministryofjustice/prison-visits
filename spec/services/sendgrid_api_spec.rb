require 'rails_helper'

RSpec.describe SendgridApi do
  subject { described_class.new }

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
        stub_request(:post, 'https://api.sendgrid.com/api/spamreports.get.json').
          with(query: hash_including(
            'api_key'   => 'test_smtp_password',
            'api_user'  => 'test_smtp_username',
            'email'     => 'test@example.com')).
          to_return(status: 200, body: body, headers: {})
      end

      context 'error handling' do
        context 'when the API raises an exception' do
          before do
            stub_request(:post, 'https://api.sendgrid.com/api/spamreports.get.json').
              to_raise(StandardError)
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

        context 'when the API returns non-JSON' do
          let(:body) { 'Oopsy daisy' }

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
            %([
              {
                "ip": "174.36.80.219",
                "email": "test@example.com",
                "created": "2009-12-06 15:45:08"
              }
            ])
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
        stub_request(:post, 'https://api.sendgrid.com/api/bounces.get.json').
          with(query: hash_including(
            'api_key'   => 'test_smtp_password',
            'api_user'  => 'test_smtp_username',
            'email'     => 'test@example.com')).
          to_return(status: 200, body: body, headers: {})
      end

      context 'error handling' do
        context 'when the API raises an exception' do
          before do
            stub_request(:post, 'https://api.sendgrid.com/api/bounces.get.json').
              to_raise(StandardError)
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

        context 'when the API returns non-JSON' do
          let(:body) { 'Oopsy daisy' }

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
            %([
              {
                "status": "4.0.0",
                "created": "2011-09-16 22:02:19",
                "reason": "Unable to resolve MX host example.com",
                "email": "test@example.com"
              }
            ])
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
        expect(HTTParty).to receive(:post).never
        subject.bounced?('test@example.com')
      end
    end

    context 'spam_reported?' do
      it 'never says that the email address has been reported for spam' do
        expect(subject.spam_reported?('test@example.com')).to be_falsey
      end

      it 'does not talk to sendgrid' do
        expect(HTTParty).to receive(:post).never
        subject.spam_reported?('test@example.com')
      end
    end
  end
end
