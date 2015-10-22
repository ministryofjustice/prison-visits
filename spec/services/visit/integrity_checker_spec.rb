require 'rails_helper'

RSpec.describe Visit::IntegrityChecker do
  before do
    class VisitTestController
      include Visit::IntegrityChecker

      def visit
        Visit.new(visit_id: 12345,
                  prisoner: Prisoner.new(
                    prison_name: 'Rochester',
                    number: 1234))
      end

      def flash
        {}
      end

      def redirect_to(_)
      end

      def edit_prisoner_details_path
      end
    end
  end

  subject { VisitTestController.new }

  context 'checking' do
    describe '#ensure_visit_integrity' do
      context 'fails' do
        before do
          allow(subject).to receive(:required_information?).
            and_return(false)
        end

        it 'generates an alert' do
          expect(I18n).to receive(:t).
            with(:ensure_visit_integrity, scope: "controllers.shared")
          subject.ensure_visit_integrity
        end

        it 'redirects' do
          expect(subject).to receive(:redirect_to)
          expect(subject).to receive(:edit_prisoner_details_path)
          subject.ensure_visit_integrity
        end
      end
    end
  end

  describe '#required_information?' do
    context 'returns false when a visit' do
      it 'is missing a prisoner' do
        allow_any_instance_of(Visit).to receive(:prisoner).and_return(nil)
        expect(subject.required_information?).to be_falsey
      end

      it 'has a prisoner without a prison name' do
        allow_any_instance_of(Prisoner).to receive(:prison_name).and_return(nil)
        expect(subject.required_information?).to be_falsey
      end
    end
  end

  context 'logging' do
    describe '#log_any_missing_information' do
      it 'gets called by #ensure_visit_integrity' do
        expect(subject).to receive(:log_any_missing_information)
        expect(subject).to receive(:required_information?).and_return(false)
        subject.ensure_visit_integrity
      end

      context 'logs visits' do
        it 'that are missing a prisoner' do
          expect(Rails.logger).to receive(:info).with(/missing a prisoner/)
          allow_any_instance_of(Visit).to receive(:prisoner).and_return(nil)
          subject.log_any_missing_information
        end

        it 'that have a prisoner without a prison name' do
          expect(Rails.logger).to receive(:info).with(/missing a prison name/)
          allow_any_instance_of(Visit).to receive(:prisoner).
            and_return(double('prisoner', prison_name: nil, present?: true).as_null_object)
          subject.log_any_missing_information
        end

        it 'that are missing a prison' do
          expect(Rails.logger).to receive(:info).with(/missing a prison$/)
          allow_any_instance_of(Prisoner).to receive(:prison).and_return(nil)
          subject.log_any_missing_information
        end

        it 'that have a prisoner with a missing prisoner number' do
          expect(Rails.logger).to receive(:info).with(/missing a prisoner number/)
          allow_any_instance_of(Visit).to receive(:prisoner).
            and_return(double('prisoner', number: nil, blank?: false).as_null_object)
          subject.log_any_missing_information
        end

        it 'that have a prison with no slots' do
          expect(Rails.logger).to receive(:info).with(/missing a prison with slots/)
          allow_any_instance_of(Prisoner).to receive(:prison).
            and_return(object_double(Prison.new, name: 'Rochester', slots: {}))
          subject.log_any_missing_information
        end
      end
    end
  end
end
