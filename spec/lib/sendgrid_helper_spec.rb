require 'spec_helper'
require 'sendgrid_helper'

describe SendgridHelper do
  context "spam reports" do
    context "error handling" do
      [Curl::Err::CurlError, JSON::ParserError].each do |exception_class|
        it "marks the email as valid if there's an error (#{exception_class})" do
          Curl::Easy.should_receive(:perform).and_raise(exception_class)
        end
      end

      it "marks the email as valid when authentication fails" do
        JSON.stub(:parse).and_return({error: 'lol'})
      end

      after :each do
        SendgridHelper.spam_reported?('test@irrelevant.com').should be_false
      end
    end

    context "when no error" do
      it "marks an e-mail as valid" do
        JSON.should_receive(:parse).and_return(['dummy'])
        SendgridHelper.spam_reported?('test@irrelevant.com')
      end

      it "marks an e-mail as invalid" do
        JSON.should_receive(:parse).and_return([])
        SendgridHelper.spam_reported?('test@irrelevant.com')
      end
    end
  end

  context "bounced" do
    context "error handling" do
      [Curl::Err::CurlError, JSON::ParserError].each do |exception_class|
        it "marks the email as valid if there's an error (#{exception_class})" do
          Curl::Easy.should_receive(:perform).and_raise(exception_class)
        end
      end

      it "marks the email as valid when authentication fails" do
        JSON.stub(:parse).and_return({error: 'lol'})
      end

      after :each do
        SendgridHelper.bounced?('test@irrelevant.com').should be_false
      end
    end

    context "when no error" do
      it "marks an e-mail as valid" do
        JSON.should_receive(:parse).and_return(['dummy'])
        SendgridHelper.bounced?('test@irrelevant.com')
      end

      it "marks an e-mail as invalid" do
        JSON.should_receive(:parse).and_return([])
        SendgridHelper.bounced?('test@irrelevant.com')
      end
    end
  end
end
