require 'rails_helper'

RSpec.describe HealthcheckController, type: :controller do
  render_views

  context "with key restrictions" do
    context "enabled" do
      it "raises an error" do
        Rails.configuration.metrics_auth_key = ""
        expect(controller).to receive(:reject!)
        get :index
      end
    end

    context "disabled" do
      def set_mock_mailer_response(mailer, status)
        expect(mailer).to receive(:smtp_settings).and_return(
          address: host = double,
          port: port = double
        )
        expect(SendgridHelper).to receive(:smtp_alive?).with(
          host, port
        ).once.and_return(status)
      end

      before :each do
        allow(controller).to receive(:reject_without_key!)
      end

      context "when everything is OK" do
        before :each do
          set_mock_mailer_response(PrisonMailer, true)
          set_mock_mailer_response(VisitorMailer, true)
        end

        it "returns a HTTP Success status" do
          get :index
          assert_response(:success, response.status)
        end

        it "reports all services as OK" do
          get :index
          parsed_body = JSON.parse(response.body)
          expect(parsed_body['checks'].values.all?).to be_truthy
        end

        [
          'sendgrid',
          'messagelabs',
          'database',
        ].each do |service|
          it "contains a check for #{service}" do
            get :index
            parsed_body = JSON.parse(response.body)
            expect(parsed_body['checks'].has_key?(service)).to be_truthy
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
          expect(ActiveRecord::Base.connection).to receive(:active?).once.and_return(false)
        end

        it_behaves_like "a service is broken", "database"
      end

      context "when the database is off" do
        before :each do
          set_mock_mailer_response(PrisonMailer, true)
          set_mock_mailer_response(VisitorMailer, true)
          expect(ActiveRecord::Base.connection).to receive(:active?).once.and_raise(PG::ConnectionBad)
        end

        it_behaves_like "a service is broken", "database"
      end
    end
  end
end
