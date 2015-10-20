require 'rails_helper'

RSpec.describe VisitorsDetailsController, type: :controller do
  render_views

  before :each do
    session[:visit] = PrisonerDetailsController.new.new_session
    controller.visit.prison_name = 'Cardiff'
    cookies['cookies-enabled'] = 1
  end

  it_behaves_like "a browser without a session present"
  it_behaves_like "a session timed out"
  it_behaves_like "a visitor data manipulator with valid data"
  it_behaves_like "a visitor data manipulator with invalid data"

  let :single_visitor_hash do
    [
      first_name: 'Sue',
      last_name: 'Demin',
      date_of_birth: {
        day: '14',
        month: '03',
        year: '1986'
      },
      email: 'sue.denim@maildrop.dsd.io',
      phone: '07783 123 456'
    ]
  end

  context "given valid visitor information" do
    let(:visitor_hash) do
      {
        visit: {
          visitor: [
            first_name: 'Sue',
            last_name: 'Demin',
            date_of_birth: {
              day: '14',
              month: '03',
              year: '1986'
            },
            email: 'sue.denim@maildrop.dsd.io',
            phone: '07783 123 456'
          ]
        },
        next: ''
      }
    end

    it "updates visitor information" do
      get :edit
      expect {
        post :update, visitor_hash
        expect(response).to redirect_to edit_slots_path
      }.to change { session[:visit].visitors.first.first_name }
    end
  end

  context "given a visitor with two digit year component of DOB" do
    let :visitor_hash do
      {
        visit: {
          visitor: [
            first_name: 'James',
            last_name: 'Harris',
            date_of_birth: {
              day: '5',
              month: '3',
              year: '12'
            },
            email: 'sue.denim@maildrop.dsd.io',
            phone: '07783 123 456'
          ]
        },
        next: ''
      }
    end

    it "rejects visitor information" do
      post :update, visitor_hash
      expect(response).to redirect_to(edit_visitors_details_path)
    end
  end

end
