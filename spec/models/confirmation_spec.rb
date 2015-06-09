require 'rails_helper'

RSpec.describe Confirmation do

  context 'errors' do
    subject { described_class.new }

    describe 'outcome' do
      context 'when outcome is a listed outcome' do
        it 'is valid when visitor is not listed and visitor is banned' do
          subject.outcome = 'no_vos_left'
          subject.visitor_not_listed = true
          subject.visitor_banned = true
          subject.valid?
          expect(subject.errors[:outcome]).to be_blank
        end

        it 'is valid when visitor is not listed and visitor is not banned' do
          subject.outcome = 'no_vos_left'
          subject.visitor_not_listed = true
          subject.visitor_banned = false
          subject.valid?
          expect(subject.errors[:outcome]).to be_blank
        end

        it 'is valid when visitor is listed and visitor is banned' do
          subject.outcome = 'no_vos_left'
          subject.visitor_not_listed = false
          subject.visitor_banned = true
          subject.valid?
          expect(subject.errors[:outcome]).to be_blank
        end

        it 'is valid when visitor is listed and visitor is not banned' do
          subject.outcome = 'no_vos_left'
          subject.visitor_not_listed = false
          subject.visitor_banned = false
          subject.valid?
          expect(subject.errors[:outcome]).to be_blank
        end
      end

      context 'when outcome is bogus' do
        it 'is valid when visitor is not listed and visitor is banned' do
          subject.outcome = 'BOGUS'
          subject.visitor_not_listed = true
          subject.visitor_banned = true
          subject.valid?
          expect(subject.errors[:outcome]).to be_blank
        end

        it 'is valid when visitor is not listed and visitor is not banned' do
          subject.outcome = 'BOGUS'
          subject.visitor_not_listed = true
          subject.visitor_banned = false
          subject.valid?
          expect(subject.errors[:outcome]).to be_blank
        end

        it 'is valid when visitor is listed and visitor is banned' do
          subject.outcome = 'BOGUS'
          subject.visitor_not_listed = false
          subject.visitor_banned = true
          subject.valid?
          expect(subject.errors[:outcome]).to be_blank
        end

        it 'is invalid when visitor is listed and visitor is not banned' do
          subject.outcome = 'BOGUS'
          subject.visitor_not_listed = false
          subject.visitor_banned = false
          subject.valid?
          expect(subject.errors[:outcome]).to include('an outcome must be chosen')
        end
      end
    end

    describe 'vo_number' do
      context 'when outcome is not a slot' do
        before do
          subject.outcome = 'no_vos_left'
        end

        it 'is valid when vo_number is present and canned_response is true' do
          subject.vo_number = '1234abcd12'
          subject.canned_response = true
          subject.valid?
          expect(subject.errors[:vo_number]).to be_blank
        end

        it 'is valid when vo_number is present and canned_response is false' do
          subject.vo_number = '1234abcd12'
          subject.canned_response = false
          subject.valid?
          expect(subject.errors[:vo_number]).to be_blank
        end

        it 'is valid when vo_number is blank and canned_response is true' do
          subject.vo_number = ''
          subject.canned_response = true
          subject.valid?
          expect(subject.errors[:vo_number]).to be_blank
        end

        it 'is valid when vo_number is blank and canned_response is false' do
          subject.vo_number = ''
          subject.canned_response = false
          subject.valid?
          expect(subject.errors[:vo_number]).to be_blank
        end
      end

      context 'when outcome is a slot' do
        before do
          subject.outcome = 'slot_0'
        end

        it 'is valid when vo_number is present and canned_response is true' do
          subject.vo_number = '1234abcd12'
          subject.canned_response = true
          subject.valid?
          expect(subject.errors[:vo_number]).to be_blank
        end

        it 'is valid when vo_number is present and canned_response is false' do
          subject.vo_number = '1234abcd12'
          subject.canned_response = false
          subject.valid?
          expect(subject.errors[:vo_number]).to be_blank
        end

        it 'is invalid when vo_number is blank and canned_response is true' do
          subject.vo_number = ''
          subject.canned_response = true
          subject.valid?
          expect(subject.errors[:vo_number]).
            to include('you must supply a reference number')
        end

        it 'is valid when vo_number is blank and canned_response is false' do
          subject.vo_number = ''
          subject.canned_response = false
          subject.valid?
          expect(subject.errors[:vo_number]).to be_blank
        end
      end
    end

    describe 'no_vo' do
      context 'when outcome is no_allowance' do
        before do
          subject.outcome = 'no_allowance'
        end

        it 'is valid when no_vo is present and renew_vo is present' do
          subject.no_vo = 'yes'
          subject.renew_vo = '2020-01-01'
          subject.valid?
          expect(subject.errors[:no_vo]).to be_blank
        end

        it 'is invalid when no_vo is present and renew_vo is nil' do
          subject.no_vo = 'yes'
          subject.renew_vo = nil
          subject.valid?
          expect(subject.errors[:no_vo]).
            to include('a renewal date must be chosen')
        end

        it 'is valid when no_vo is blank and renew_vo is present' do
          subject.no_vo = ''
          subject.renew_vo = '2020-01-01'
          subject.valid?
          expect(subject.errors[:no_vo]).to be_blank
        end

        it 'is valid when no_vo is blank and renew_vo is nil' do
          subject.no_vo = ''
          subject.renew_vo = nil
          subject.valid?
          expect(subject.errors[:no_vo]).to be_blank
        end
      end

      context 'when outcome is not no_allowance' do
        before do
          subject.outcome = 'prisoner_incorrect'
        end

        it 'is valid when no_vo is present and renew_vo is present' do
          subject.no_vo = 'yes'
          subject.renew_vo = '2020-01-01'
          subject.valid?
          expect(subject.errors[:no_vo]).to be_blank
        end

        it 'is valid when no_vo is present and renew_vo is nil' do
          subject.no_vo = 'yes'
          subject.renew_vo = nil
          subject.valid?
          expect(subject.errors[:no_vo]).to be_blank
        end

        it 'is valid when no_vo is blank and renew_vo is present' do
          subject.no_vo = ''
          subject.renew_vo = '2020-01-01'
          subject.valid?
          expect(subject.errors[:no_vo]).to be_blank
        end

        it 'is valid when no_vo is blank and renew_vo is nil' do
          subject.no_vo = ''
          subject.renew_vo = nil
          subject.valid?
          expect(subject.errors[:no_vo]).to be_blank
        end
      end
    end

    describe 'no_pvo' do
      context 'when outcome is no_allowance' do
        before do
          subject.outcome = 'no_allowance'
        end

        it 'is valid when no_pvo is present and renew_pvo is present' do
          subject.no_pvo = 'yes'
          subject.renew_pvo = '2020-01-01'
          subject.valid?
          expect(subject.errors[:no_pvo]).to be_blank
        end

        it 'is invalid when no_pvo is present and renew_pvo is nil' do
          subject.no_pvo = 'yes'
          subject.renew_pvo = nil
          subject.valid?
          expect(subject.errors[:no_pvo]).
            to include('a renewal date must be chosen')
        end

        it 'is valid when no_pvo is blank and renew_pvo is present' do
          subject.no_pvo = ''
          subject.renew_pvo = '2020-01-01'
          subject.valid?
          expect(subject.errors[:no_pvo]).to be_blank
        end

        it 'is valid when no_pvo is blank and renew_pvo is nil' do
          subject.no_pvo = ''
          subject.renew_pvo = nil
          subject.valid?
          expect(subject.errors[:no_pvo]).to be_blank
        end
      end

      context 'when outcome is not no_allowance' do
        before do
          subject.outcome = 'prisoner_incorrect'
        end

        it 'is valid when no_pvo is present and renew_pvo is present' do
          subject.no_pvo = 'yes'
          subject.renew_pvo = '2020-01-01'
          subject.valid?
          expect(subject.errors[:no_pvo]).to be_blank
        end

        it 'is valid when no_pvo is present and renew_pvo is nil' do
          subject.no_pvo = 'yes'
          subject.renew_pvo = nil
          subject.valid?
          expect(subject.errors[:no_pvo]).to be_blank
        end

        it 'is valid when no_pvo is blank and renew_pvo is present' do
          subject.no_pvo = ''
          subject.renew_pvo = '2020-01-01'
          subject.valid?
          expect(subject.errors[:no_pvo]).to be_blank
        end

        it 'is valid when no_pvo is blank and renew_pvo is nil' do
          subject.no_pvo = ''
          subject.renew_pvo = nil
          subject.valid?
          expect(subject.errors[:no_pvo]).to be_blank
        end
      end
    end

    describe 'banned' do
      it 'is valid when visitor_banned is true and banned_visitors is present' do
        subject.visitor_banned = true
        subject.banned_visitors = ['John;Smith']
        subject.valid?
        expect(subject.errors[:banned]).to be_blank
      end

      it 'is invalid when visitor_banned is true and banned_visitors is nil' do
        subject.visitor_banned = true
        subject.banned_visitors = nil
        subject.valid?
        expect(subject.errors[:banned]).
          to include('one or more visitors must be selected')
      end

      it 'is valid when visitor_banned is false and banned_visitors is present' do
        subject.visitor_banned = false
        subject.banned_visitors = ['John;Smith']
        subject.valid?
        expect(subject.errors[:banned]).to be_blank
      end

      it 'is valid when visitor_banned is false and banned_visitors is nil' do
        subject.visitor_banned = false
        subject.banned_visitors = nil
        subject.valid?
        expect(subject.errors[:banned]).to be_blank
      end
    end

    describe 'unlisted' do
      it 'is valid when visitor_not_listed is true and unlisted_visitors is present' do
        subject.visitor_not_listed = true
        subject.unlisted_visitors = ['John;Smith']
        subject.valid?
        expect(subject.errors[:unlisted]).to be_blank
      end

      it 'is invalid when visitor_not_listed is true and unlisted_visitors is nil' do
        subject.visitor_not_listed = true
        subject.unlisted_visitors = nil
        subject.valid?
        expect(subject.errors[:unlisted]).
          to include('one or more visitors must be selected')
      end

      it 'is valid when visitor_not_listed is false and unlisted_visitors is present' do
        subject.visitor_not_listed = false
        subject.unlisted_visitors = ['John;Smith']
        subject.valid?
        expect(subject.errors[:unlisted]).to be_blank
      end

      it 'is valid when visitor_not_listed is false and unlisted_visitors is nil' do
        subject.visitor_not_listed = false
        subject.unlisted_visitors = nil
        subject.valid?
        expect(subject.errors[:unlisted]).to be_blank
      end
    end
  end
end
