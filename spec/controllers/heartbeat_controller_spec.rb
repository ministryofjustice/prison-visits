require 'spec_helper'

describe HeartbeatController do
  render_views

  context "with key restrictions" do
    context "enabled" do
      it "raises an error" do
        Rails.configuration.metrics_auth_key = ""
        controller.should_receive(:reject!)
        get :healthcheck
      end
    end

    context "disabled" do
      def set_mock_mailer_response(mailer, status)
        mailer.should_receive(:smtp_settings).and_return(
          address: host = double,
          port: port = double
        )
        SendgridHelper.should_receive(:smtp_alive?).with(
          host, port
        ).once.and_return(status)
      end

      before :each do
        controller.stub(:reject_without_key!)
      end

      context "when everything is OK" do
        before :each do
          set_mock_mailer_response(PrisonMailer, true)
          set_mock_mailer_response(VisitorMailer, true)
        end

        it "returns a HTTP Success status" do
          get :healthcheck
          assert_response(:success, response.status)
        end

        it "reports all services as OK" do
          get :healthcheck
          parsed_body = JSON.parse(response.body)
          parsed_body['checks'].values.all?.should be_true
        end

        [
          'sendgrid',
          'messagelabs',
          'database',
        ].each do |service|
          it "contains a check for #{service}" do
            get :healthcheck
            parsed_body = JSON.parse(response.body)
            parsed_body['checks'].has_key?(service).should be_true
          end
        end
      end

      context "when messagelabs is down" do
        before :each do
          set_mock_mailer_response(PrisonMailer, false)
          set_mock_mailer_response(VisitorMailer, true)
        end

        it_behaves_like "a service is broken", "messagelabs"
      end

      context "when sendgrid is down" do
        before :each do
          set_mock_mailer_response(PrisonMailer, true)
          set_mock_mailer_response(VisitorMailer, false)
        end

        it_behaves_like "a service is broken", "sendgrid"
      end

      context "when the database is down" do
        before :each do
          set_mock_mailer_response(PrisonMailer, true)
          set_mock_mailer_response(VisitorMailer, true)
          ActiveRecord::Base.connection.should_receive(:active?).once.and_return(false)
        end

        it_behaves_like "a service is broken", "database"
      end
    end
  end
end
