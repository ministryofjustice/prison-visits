require 'rails_helper'
require 'sendgrid_helper'

RSpec.describe SendgridHelper do
  context "spam reports" do
    context "error handling" do
      [Curl::Err::CurlError, JSON::ParserError].each do |exception_class|
        it "marks the email as valid if there's an error (#{exception_class})" do
          expect(Curl::Easy).to receive(:perform).and_raise(exception_class)
        end
      end

      it "marks the email as valid when authentication fails" do
        allow(JSON).to receive(:parse).and_return({error: 'lol'})
      end

      after :each do
        expect(SendgridHelper.spam_reported?('test@irrelevant.com')).to be_falsey
      end
    end

    context "when no error" do
      it "marks an e-mail as valid" do
        expect(JSON).to receive(:parse).and_return(['dummy'])
        SendgridHelper.spam_reported?('test@irrelevant.com')
      end

      it "marks an e-mail as invalid" do
        expect(JSON).to receive(:parse).and_return([])
        SendgridHelper.spam_reported?('test@irrelevant.com')
      end
    end
  end

  context "bounced" do
    context "error handling" do
      [Curl::Err::CurlError, JSON::ParserError].each do |exception_class|
        it "marks the email as valid if there's an error (#{exception_class})" do
          expect(Curl::Easy).to receive(:perform).and_raise(exception_class)
        end
      end

      it "marks the email as valid when authentication fails" do
        allow(JSON).to receive(:parse).and_return({error: 'lol'})
      end

      after :each do
        expect(SendgridHelper.bounced?('test@irrelevant.com')).to be_falsey
      end
    end

    context "when no error" do
      it "marks an e-mail as valid" do
        expect(JSON).to receive(:parse).and_return(['dummy'])
        SendgridHelper.bounced?('test@irrelevant.com')
      end

      it "marks an e-mail as invalid" do
        expect(JSON).to receive(:parse).and_return([])
        SendgridHelper.bounced?('test@irrelevant.com')
      end
    end
  end

  context "sendgrid connection test" do
    let :host do
      'smtp.sendgrid.net'
    end

    let :port do
      587
    end

    context "when it connects" do
      it "will return true" do 
        expect(Net::SMTP).to receive(:start)
        expect(SendgridHelper.smtp_alive?(host, port)).to be_truthy
      end
    end

    context "when it times out" do
      it "will return false" do
        expect(Net::SMTP).to receive(:start).and_raise(Net::OpenTimeout)
        expect(SendgridHelper.smtp_alive?(host, port)).to be_falsey
      end
    end

    context "when the port is closed" do
      it "will return false" do
        expect(Net::SMTP).to receive(:start).and_raise(Errno::ECONNREFUSED)
        expect(SendgridHelper.smtp_alive?(host, port)).to be_falsey
      end
    end

    context "when the hostname cannot be resolved" do
      it "will return false" do
        expect(Net::SMTP).to receive(:start).and_raise(SocketError)
        expect(SendgridHelper.smtp_alive?(host, port)).to be_falsey
      end
    end
  end
end
